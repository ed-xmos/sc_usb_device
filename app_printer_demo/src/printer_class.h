/*
 * printer_class.h
 *
 *  Created on: Jul 8, 2014
 *      Author: Ed
 */

#ifndef PRINTER_CLASS_H_
#define PRINTER_CLASS_H_

//USB sub class
#define USB_PRINTER_SUBCLASS        0x01

//Printer interface types
#define USB_PRINTER_UNIDIRECTIONAL  0x01
#define USB_PRINTER_BIDIRECTIONAL   0x02
#define USB_PRINTER_1284_4_COMPAT   0x03

//Request types
#define PRINTER_GET_DEVICE_ID       0x00
#define PRINTER_GET_PORT_STATUS     0x01
#define PRINTER_SOFT_RESET          0x02

#endif /* PRINTER_CLASS_H_ */
