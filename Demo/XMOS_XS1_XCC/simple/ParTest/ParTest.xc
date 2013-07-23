/********************************************************************************
 * File:     ParTest.xc                                                         *
 * Author:   Bianco Zandbergen  (bianco [at] zandbergen [dot] name)             *
 * Changes:  17 feb 2010, initial release                                       *
 *                                                                              *
 * C files cannot touch ports.                                                  *
 * This file handles the LED's.                                                 *
 *                                                                              *
 ********************************************************************************/
#include <platform.h>
#include <xs1.h>

#if BOARD == XC_1
out port leds = 		XS1_PORT_8D;
unsigned long mask =	0xF0;
#elif BOARD == XC_1A
out port leds =			XS1_PORT_4C;
unsigned long mask =	0x0F;
#elif BOARD == XC_2
out port leds =			XS1_PORT_1E;
unsigned long mask =	0x01;
#elif BOARD == XC_3
out port leds =	
unsigned long mask =
#elif BOARD == XC_5
out port leds =			XS1_PORT_4E;
unsigned long mask = 	0x0F;
#elif BOARD == XK_1
out port leds =			XS1_PORT_4F;
unsigned long mask =	0x0F;
#elif BOARD == XDK
out port leds =			XS1_PORT_1F;
unsigned long mask =	0x01;
#else
out port leds =
unsigned long mask =
#endif

void vParTestInitialise( void )
{

}

int vParTestSetLed(unsigned long value)
{
	if (value != 0) {
		leds <: mask;	
	} else {
		leds <: 0x00;
	}

	return 0;
}


