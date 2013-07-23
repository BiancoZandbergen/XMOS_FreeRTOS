#include <platform.h>
#include <xs1.h>

#if BOARD == XC_1
on stdcore[0] : out port leds = 		XS1_PORT_8D;
unsigned long mask =					0xF0;
#elif BOARD == XC_1A
on stdcore[0] : out port leds =			XS1_PORT_4C;
unsigned long mask =					0x0F;
#elif BOARD == XC_2
on stdcore[0] : out port leds =			XS1_PORT_1E;
unsigned long mask =					0x01;
#elif BOARD == XC_3
on stdcore[0] : out port leds =	
unsigned long mask =
#elif BOARD == XC_5
on stdcore[0] : out port leds =			XS1_PORT_4E;
unsigned long mask = 					0x0F;
#elif BOARD == XK_1
on stdcore[0] : out port leds =			XS1_PORT_4F;
unsigned long mask =					0x0F;
#elif BOARD == XDK
on stdcore[0] : out port leds =			XS1_PORT_1F;
unsigned long mask =					0x01;
#else
on stdcore[0] : out port leds =
unsigned long mask =
#endif

int vParTestInitialise( void )
{
	return 0;
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


