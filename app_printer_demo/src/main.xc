/**
 * The copyrights, all other intellectual and industrial
 * property rights are retained by XMOS and/or its licensors.
 * Terms and conditions covering the use of this code can
 * be found in the Xmos End User License Agreement.
 *
 * Copyright XMOS Ltd 2013
 *
 * In the case where this code is a modification of existing code
 * under a separate license, the separate license terms are shown
 * below. The modifications to the code are still covered by the
 * copyright notice above.
 *
 **/

#include <xscope.h>
#include "xud.h"
#include "debug_print.h"

#if (USE_XSCOPE == 1)
void xscope_user_init(void) {
    xscope_register(0, 0, "", 0, "");
    xscope_config_io(XSCOPE_IO_BASIC);
}
#endif

#define XUD_EP_COUNT_OUT   2    //Includes EP0
#define XUD_EP_COUNT_IN    2    //Includes EP0


#if (U16 == 1)
#define PWR_MODE XUD_PWR_SELF
#else
#define PWR_MODE XUD_PWR_BUS
#endif

/* Prototype for Endpoint0 function in endpoint0.xc */
void Endpoint0(chanend c_ep0_out, chanend c_ep0_in);

/* Endpoint type tables - informs XUD what the transfer types for each Endpoint in use and also
 * if the endpoint wishes to be informed of USB bus resets
 */
XUD_EpType epTypeTableOut[XUD_EP_COUNT_OUT] = {XUD_EPTYPE_CTL | XUD_STATUS_ENABLE, XUD_EPTYPE_BUL};
XUD_EpType epTypeTableIn[XUD_EP_COUNT_IN] =   {XUD_EPTYPE_CTL | XUD_STATUS_ENABLE, XUD_EPTYPE_BUL};

#if (XUD_SERIES_SUPPORT == XUD_U_SERIES)
  /* USB Reset not required for U series - pass null to XUD */
  #define p_usb_rst null
  #define clk_usb_rst null
#else
  /* USB reset port declarations for L series */
  on USB_TILE: out port p_usb_rst   = PORT_USB_RESET;
  on USB_TILE: clock    clk_usb_rst = XS1_CLKBLK_3;
#endif

/* Global report buffer, global since used by Endpoint0 core */
unsigned char g_reportBuffer[] = {0, 0, 0, 0};

  #if (XUD_SERIES_SUPPORT == XUD_L_SERIES)
    #error NO ADC ON L-SERIES
  #endif

  #include <xs1_su.h>
  #include "usb_tile_support.h"

  /* Port for ADC triggering */
  on USB_TILE: out port p_adc_trig = PORT_ADC_TRIGGER;


void print_string(unsigned char *string, unsigned length)
{
    unsigned char *character;
    for (int i=0; i<length; i++)
    {
        character = string + i;
        debug_printf(character);
    }
    debug_printf("\n");
}


/*
 * This function responds to the HID requests - it moves the pointers x axis based on ADC input
 */
void printer_main(chanend c_ep_prt_out, chanend c_ep_prt_in, chanend c_adc)
{
    unsigned data[2]; //For ADC

    unsigned size;
    unsigned char print_packet[1024];

    /* Initialise the XUD endpoints */
    XUD_ep ep_out = XUD_InitEp(c_ep_prt_out);
    XUD_ep ep_in = XUD_InitEp(c_ep_prt_in);

    /* Configure and enable the ADC in the U device */
    adc_config_t adc_config = { { 0, 0, 0, 0, 0, 0, 0, 0 }, 0, 0, 0 };

    {
        adc_config.input_enable[0] = 1;
        adc_config.samples_per_packet = 1;
    }
    adc_config.bits_per_sample = ADC_32_BPS;
    adc_config.calibration_mode = 0;

    adc_enable(usb_tile, c_adc, p_adc_trig, adc_config);

    while (1)
    {

        /* Get ADC input */
        adc_trigger_packet(p_adc_trig, adc_config);
        adc_read_packet(c_adc, adc_config, data);

        XUD_GetBuffer(ep_out, print_packet, size); //TODO work out what should come here
        debug_printf("Received %d print data bytes\n", size);

        print_string(print_packet, size);
    }
}



/*
 * The main function runs three cores: the XUD manager, Endpoint 0, and a HID endpoint. An array of
 * channels is used for both IN and OUT endpoints, endpoint zero requires both, HID requires just an
 * IN endpoint to send HID reports to the host.
 */
int main()
{
    chan c_ep_out[XUD_EP_COUNT_OUT], c_ep_in[XUD_EP_COUNT_IN];

    chan c_adc;

    par
    {
        on USB_TILE: XUD_Manager(c_ep_out, XUD_EP_COUNT_OUT, c_ep_in, XUD_EP_COUNT_IN,
                                null, epTypeTableOut, epTypeTableIn,
                                p_usb_rst, clk_usb_rst, -1, XUD_SPEED_HS, PWR_MODE);

        on USB_TILE: Endpoint0(c_ep_out[0], c_ep_in[0]);

        on USB_TILE: printer_main(c_ep_out[1], c_ep_in[1], c_adc);

        xs1_su_adc_service(c_adc);
    }

    return 0;
}
