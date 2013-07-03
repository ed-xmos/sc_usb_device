.. _usb_device_design_guide:

Overview
========

This document describes how to create an Endpoint 0 implementation
and provides a worked example that uses the XUD library; a USB Human
Interface Device (HID) Class compliant mouse.

This document assumes familiarity with the XMOS xCORE
architecture, the Universal Serial Bus 2.0 Specification (and
related specifications), the XMOS tool chain and XC language.

Features
++++++++

   * Support for USB 2.0 full and high speed devices.

Memory requirements
+++++++++++++++++++

The approximate memory usage for the USB device library including the XUD
library is:

+------------------+---------------+
|                  | Usage         |
+==================+===============+
| Stack            | 2kB           |
+------------------+---------------+
| Program          | 12kB          |
+------------------+---------------+

Resource requirements
+++++++++++++++++++++

The resources used by the USB device and XUD libraries combined are shown below:

+------------------+-----------------+-----------------+
|                  | U-Series        | L-Series        |
+==================+=================+=================+
| Logical Cores    | 2 plus one per  | 2 plus one per  |
|                  | endpoint        | endpoint        |
+------------------+-----------------+-----------------+
| Channels         | 2 for Endpoint0 | 2 for Endpoint0 |
|                  | and 1 additional| and 1 additional|
|                  | per IN and OUT  | per IN and OUT  |
|                  | endpoint        | endpoint        |
+------------------+-----------------+-----------------+
| Timers           | 4 timers        | 4 timers        |
+------------------+-----------------+-----------------+
| Clock blocks     | Clock blocks    | Clock block 0   |
|                  | 4 and 5         |                 |
+------------------+-----------------+-----------------+

*Note:* On the L-Series the XUD library uses clock block 0 and configures it 
to be clocked by the 60MHz clock from the ULPI transceiver. The ports it
uses are in turn clocked from the clock block. Since clock block 0 is
the default for all ports when enabled it is important that if a port
is not required to be clocked from this 60MHz clock, then it is configured
to use another clock block.

Core Speed
++++++++++

Due to I/O requirements, the library requires a guaranteed MIPS rate to
ensure correct operation. This means that core count restrictions must
be observed. The XUD core must run at at least 80 MIPS.

This means that for an xCORE device running at 400MHz there should be no more
than five cores executing at any time when using the XUD. For
a 500MHz device no more than six cores shall execute at any one time
when using the XUD.

This restriction is only a requirement on the tile on which the XUD is running. 
For example, a different tile on an L16 device is unaffected by this restriction.

Ports/Pins
++++++++++

L-Series
........

The ports used for the physical connection to the external ULPI transceiver must
be connected as shown in :ref:`table_usb_device_ulpi_required_pin_port`.

.. _table_usb_device_ulpi_required_pin_port:

.. table:: L-Series required pin/port connections
    :class: horizontal-borders vertical_borders

    +-------+-------+------+-------+---------------------+
    | Pin   | Port                 | Signal              |
    |       +-------+------+-------+---------------------+
    |       | 1b    | 4b   | 8b    |                     |
    +=======+=======+======+=======+=====================+
    | X0D12 | P1E0  |              | ULPI_STP            |
    +-------+-------+------+-------+---------------------+
    | X0D13 | P1F0  |              | ULPI_NXT            |
    +-------+-------+------+-------+---------------------+
    | X0D14 |       | P4C0 | P8B0  | ULPI_DATA[7:0]      |
    +-------+       +------+-------+                     |
    | X0D15 |       | P4C1 | P8B1  |                     |
    +-------+       +------+-------+                     |
    | X0D16 |       | P4D0 | P8B2  |                     |
    +-------+       +------+-------+                     |
    | X0D17 |       | P4D1 | P8B3  |                     |
    +-------+       +------+-------+                     |
    | X0D18 |       | P4D2 | P8B4  |                     |
    +-------+       +------+-------+                     |
    | X0D19 |       | P4D3 | P8B5  |                     |
    +-------+       +------+-------+                     |
    | X0D20 |       | P4C2 | P8B6  |                     |
    +-------+       +------+-------+                     |
    | X0D21 |       | P4C3 | P8B7  |                     |
    +-------+-------+------+-------+---------------------+
    | X0D22 | P1G0  |              | ULPI_DIR            |
    +-------+-------+------+-------+---------------------+
    | X0D23 | P1H0  |              | ULPI_CLK            |
    +-------+-------+------+-------+---------------------+
    | X0D24 | P1I0  |              | ULPI_RST_N          |
    +-------+-------+------+-------+---------------------+

In addition some ports are used internally when the XUD library is in
operation. For example pins X0D2-X0D9, X0D26-X0D33 and X0D37-X0D43 on
an XS1-L8-128 device should not be used. 

Please refer to the device datasheet for further information on which ports
are available.

U-Series
........

The U-Series of processors has an integrated USB transceiver. Some ports
are used to communicate with the USB transceiver inside the U-Series packages.
These ports/pins should not be used when USB functionality is enabled.
The ports/pins are shown in :ref:`table_usb_device_u_required_pin_port`.

.. _table_usb_device_u_required_pin_port:

.. table:: U-Series required pin/port connections
    :class: horizontal-borders vertical_borders

    +-------+-------+------+-------+-------+--------+
    | Pin   | Port                                  |                
    |       +-------+------+-------+-------+--------+
    |       | 1b    | 4b   | 8b    | 16b   | 32b    |                    
    +=======+=======+======+=======+=======+========+
    | X0D02 |       | P4A0 | P8A0  | P16A0 | P32A20 |
    +-------+-------+------+-------+-------+--------+
    | X0D03 |       | P4A1 | P8A1  | P16A1 | P32A21 |
    +-------+-------+------+-------+-------+--------+
    | X0D04 |       | P4B0 | P8A2  | P16A2 | P32A22 |
    +-------+-------+------+-------+-------+--------+
    | X0D05 |       | P4B1 | P8A3  | P16A3 | P32A23 |
    +-------+-------+------+-------+-------+--------+
    | X0D06 |       | P4B2 | P8A4  | P16A4 | P32A24 |
    +-------+-------+------+-------+-------+--------+
    | X0D07 |       | P4B3 | P8A5  | P16A5 | P32A25 |
    +-------+-------+------+-------+-------+--------+
    | X0D08 |       | P4A2 | P8A6  | P16A6 | P32A26 |
    +-------+-------+------+-------+-------+--------+
    | X0D09 |       | P4A3 | P8A7  | P16A7 | P32A27 |
    +-------+-------+------+-------+-------+--------+
    | X0D23 | P1H0  |                               |
    +-------+-------+------+-------+-------+--------+
    | X0D25 | P1J0  |                               | 
    +-------+-------+------+-------+-------+--------+
    | X0D26 |       | P4E0 | P8C0  | P16B0 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D27 |       | P4E1 | P8C1  | P16B1 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D28 |       | P4F0 | P8C2  | P16B2 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D29 |       | P4F1 | P8C3  | P16B3 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D30 |       | P4F2 | P8C4  | P16B4 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D31 |       | P4F3 | P8C5  | P16B5 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D32 |       | P4E2 | P8C6  | P16B6 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D33 |       | P4E3 | P8C7  | P16B7 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D34 | P1K0  |                               |
    +-------+-------+------+-------+-------+--------+
    | X0D36 | P1M0  |      | P8D0  | P16B8 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D37 | P1N0  |      | P8C1  | P16B1 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D38 | P1O0  |      | P8C2  | P16B2 |        |
    +-------+-------+------+-------+-------+--------+
    | X0D39 | P1P0  |      | P8C3  | P16B3 |        |
    +-------+-------+------+-------+-------+--------+

