/**
 * The copyrights, all other intellectual and industrial
 * property rights are retained by XMOS and/or its licensors.
 * Terms and conditions covering the use of this code can
 * be found in the Xmos End User License Agreement.
 *
 * Copyright XMOS Ltd 2014
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
#include "print.h"

#if (USE_XSCOPE == 1)
void xscope_user_init(void) {
    xscope_register(0, 0, "", 0, "");
    xscope_config_io(XSCOPE_IO_BASIC); /* Enable fast printing over links */
}
#endif

#define XUD_EP_COUNT_OUT   2    //Includes EP0 (1 out EP0 + Printer data output EP)
#define XUD_EP_COUNT_IN    1    //Includes EP0 (1 in EP0)


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
XUD_EpType epTypeTableIn[XUD_EP_COUNT_IN] =   {XUD_EPTYPE_CTL | XUD_STATUS_ENABLE};

/* Using U-series so reset lines not required (set to null). Passed to XUD task */
  #define p_usb_rst null
  #define clk_usb_rst null


/* Global report buffer, global since used by Endpoint0 core */
unsigned char g_reportBuffer[] = {0, 0, 0, 0};


/* Version of print string that doesn't terminate on null */
void print_string(unsigned char *string, unsigned size)
{
    for (int i=0; i<size; i++)
    {
        switch(*string){
            /* ignore nulls */
            case 0x00:
            break;

#ifdef IGNORE_WHITESPACE
            case 0x20:  //space
            case 0x0a:  //tab
            break;
#endif

            default:
            printchar(*string);
            break;
        }
        string++;
    }
    printchar('\n');
}


/*
 * This function receives the printer endpoint transfers from the host */
void printer_main(chanend c_ep_prt_out)
{
    unsigned size;
    unsigned char print_packet[1024]; /* Buffer for storing printer packets sent from host */

    debug_printf("USB printer class demo started\n");

    /* Initialise the XUD endpoints */
    XUD_ep ep_out = XUD_InitEp(c_ep_prt_out);

    while (1)
    {
        XUD_GetBuffer(ep_out, print_packet, size);          /* Blocking read on the endpoint buffer */
        debug_printf("**** Received %d byte print buffer ****\n", size);
        print_string(print_packet, size);
    }
}



/*
 * The main function runs three cores: the XUD manager, Endpoint 0, and a Printer endpoint. An array of
 * channels is used for both IN and OUT endpoints
 */
int main()
{
    chan c_ep_out[XUD_EP_COUNT_OUT], c_ep_in[XUD_EP_COUNT_IN];

    par
    {
        on USB_TILE: XUD_Manager(c_ep_out, XUD_EP_COUNT_OUT, c_ep_in, XUD_EP_COUNT_IN,
                                null, epTypeTableOut, epTypeTableIn,
                                p_usb_rst, clk_usb_rst, -1, XUD_SPEED_HS, PWR_MODE);

        on USB_TILE: Endpoint0(c_ep_out[0], c_ep_in[0]);

        on USB_TILE: printer_main(c_ep_out[1]);

    }
    return 0;
}
