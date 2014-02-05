The demo in the simple directory contains the basic demonstration.
The demo runs three tests:

- Integer test
- Blocking queue test
- Polled queue test

A fourth process checks if these tasks are running and blinks one or more LED's.
The LED's do not blink or stop blinking when something goed wrong.

This demo can be configured to run on multiple boards.
This can be defined in the makefile.

Supported boards are: XC-1, XC-1A, XC2, XC-5, XK-1, XDK
(not all of them are tested though)

Current API calls tested on this port:

xTaskCreate
vTaskDelay
vTaskDelayUntil
xQueueCreate
xQueueSend
xQueueReceive

Modifications to the common code that breaks with other ports:

Currently none

For any questions contact the author of this port at
bianco [at] zandbergen [dot] name

