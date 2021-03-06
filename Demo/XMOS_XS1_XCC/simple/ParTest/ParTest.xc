/********************************************************************************
 * File:     ParTest.xc                                                         *
 * Author:   Bianco Zandbergen  (bianco [at] zandbergen [dot] name)             *
 * Changes:  17 feb 2010, initial release                                       *
 *           4  feb 2014, added STARTKIT                                        *
 *                                                                              *
 * C files cannot touch ports.                                                  *
 * This file handles the LED's.                                                 *
 *                                                                              *
 ********************************************************************************/
#include <platform.h>
#include <xs1.h>

#if defined(XC_1)
on stdcore[0] : out port leds = XS1_PORT_8D;
unsigned long mask            = 0xF0;
#elif defined(XC_1A)
on stdcore[0] : out port leds = XS1_PORT_4C;
unsigned long mask            = 0x0F;
#elif defined(XC_2)
on stdcore[0] : out port leds = XS1_PORT_1E;
unsigned long mask            = 0x01;
#elif defined(XC_3)
on stdcore[0] : out port leds =
unsigned long mask            =
#elif defined(XC_5)
on stdcore[0] : out port leds = XS1_PORT_4E;
unsigned long mask            = 0x0F;
#elif defined(XK_1)
on stdcore[0] : out port leds = XS1_PORT_4F;
unsigned long mask            = 0x0F;
#elif defined(XK_1A)
on stdcore[0] : out port leds = XS1_PORT_4F;
unsigned long mask            = 0x0F;
#elif defined(XDK)
on stdcore[0] : out port leds = XS1_PORT_1F;
unsigned long mask            = 0x01;
#elif defined(STARTKIT)
on stdcore[0] : out port leds = XS1_PORT_1A;
unsigned long mask            = 0x01;
#else
on stdcore[0] : out port leds =
unsigned long mask            =
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


