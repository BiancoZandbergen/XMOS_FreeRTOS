This directory contains two demo's for the XMOS XS1 architecture port.

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

The demo in the XC1_multithread directory shows how
to use FreeRTOS together with other hardware threads
on the same and other cores. This demo can only be run from
the XC-1 (not XC-1A!) board without modification. The main routine
is moved from main.c to par.xc.

Current API calls tested on this port:

xTaskCreate
vTaskDelay
vTaskDelayUntil
xQueueCreate
xQueueSend
xQueueReceive

Modifications to the common code that breaks with other ports:

xQueueHandle is defined as struct QueueDefinition{} * instead of void *
in Source/include/queue.h

For any questions contact the author of this port at
bianco [at] zandbergen [dot] name

