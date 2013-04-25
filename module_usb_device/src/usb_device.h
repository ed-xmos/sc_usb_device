/*
 * The copyrights, all other intellectual and industrial 
 * property rights are retained by XMOS and/or its licensors. 
 * Terms and conditions covering the use of this code can
 * be found in the Xmos End User License Agreement.
 *
 * Copyright XMOS Ltd 2010
 *
 * In the case where this code is a modification of existing code
 * under a separate license, the separate license terms are shown
 * below. The modifications to the code are still covered by the 
 * copyright notice above.
 *
 **/                                   
/* 
 * @brief      USB Device helper functions
 */

#ifndef _USB_DEVICE_H_
#define _USB_DEVICE_H_

#include "usb.h"
#include "xud.h"

/** 
  * \brief     This function performs some of the common USB standard descriptor requests.
  *            It handles the following standard requests appropriately using values passed to it:
  *
  *   Get Device Descriptor (using devDesc argument)
  *
  *   Get Configuration Descriptor (using cfgDesc argument)
  *
  *   String requests (using strDesc argument)
  *
  *   Get Microsoft OS String Descriptor (usings product ID string)
  *
  *   Get Device_Qualifier Descriptor
  *
  *   Get Other-Speed Configuration Descriptor (using oSpeedCfgDesc argument)
  *
  * \param     ep_out Channel from XUD (ep 0)
  * \param     ep_in Channel from XUD (ep 0) 
  * \param     devDesc_hs The Device descriptor to use, encoded according to the USB standard
  * \param     devDescLength_hs Length of device descriptor in bytes
  * \param     cfgDesc_hs Configuration descriptor
  * \param     cfgDescLength_hs Length of config descriptor in bytes
  * \param     devDesc_fs The Device descriptor to use, encoded according to the USB standard
  * \param     devDescLength_fs Length of device descriptor in bytes
  * \param     cfgDesc_fs Configuration descriptor
  * \param     cfgDescLength_fs Length of config descriptor in bytes
  * \param     strDescs
  * \param     sp ``USB_SetupPacket_t`` (passed by ref) in which the setup data is returned
  * \param     c_usb_test Optional channel param for USB test mode support
  * \param     usbBusSpeed TBD
  *
  *  \return This function returns 1 if the request has been dealt with successfully, 0 if not. If
  *          the request has not been dealt with then the ``USB_SetupPacket_t`` structure should
  *          be examined for device specific requests.
  *
  */
int USB_StandardRequests(XUD_ep ep_out, XUD_ep ep_in, 
        unsigned char devDesc_hs[], int devDescLength_hs, 
        unsigned char cfgDesc_hs[], int cfgDescLength_hs,
        unsigned char ?devDesc_fs[], int devDescLength_fs, 
        unsigned char ?cfgDesc_fs[], int cfgDescLength_fs, 
        unsigned char strDescs[][40], USB_SetupPacket_t &sp, chanend ?c_usb_test, unsigned usbBusSpeed);
/**
 *  \brief      TBD
 */
int USB_GetSetupPacket(XUD_ep ep_out, XUD_ep ep_in, USB_SetupPacket_t &sp);

/**
 *  \brief Prints out passed ``USB_SetupPacket_t`` struct using debug IO
 */
void USB_PrintSetupPacket(USB_SetupPacket_t sp);

#endif
