/*
    FreeRTOS V6.0.2 - Copyright (C) 2010 Real Time Engineers Ltd.

    ***************************************************************************
    *                                                                         *
    * If you are:                                                             *
    *                                                                         *
    *    + New to FreeRTOS,                                                   *
    *    + Wanting to learn FreeRTOS or multitasking in general quickly       *
    *    + Looking for basic training,                                        *
    *    + Wanting to improve your FreeRTOS skills and productivity           *
    *                                                                         *
    * then take a look at the FreeRTOS eBook                                  *
    *                                                                         *
    *        "Using the FreeRTOS Real Time Kernel - a Practical Guide"        *
    *                  http://www.FreeRTOS.org/Documentation                  *
    *                                                                         *
    * A pdf reference manual is also available.  Both are usually delivered   *
    * to your inbox within 20 minutes to two hours when purchased between 8am *
    * and 8pm GMT (although please allow up to 24 hours in case of            *
    * exceptional circumstances).  Thank you for your support!                *
    *                                                                         *
    ***************************************************************************

    This file is part of the FreeRTOS distribution.

    FreeRTOS is free software; you can redistribute it and/or modify it under
    the terms of the GNU General Public License (version 2) as published by the
    Free Software Foundation AND MODIFIED BY the FreeRTOS exception.
    ***NOTE*** The exception to the GPL is included to allow you to distribute
    a combined work that includes FreeRTOS without being obliged to provide the
    source code for proprietary components outside of the FreeRTOS kernel.
    FreeRTOS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
    more details. You should have received a copy of the GNU General Public 
    License and the FreeRTOS license exception along with FreeRTOS; if not it 
    can be viewed here: http://www.freertos.org/a00114.html and also obtained 
    by writing to Richard Barry, contact details for whom are available on the
    FreeRTOS WEB site.

    1 tab == 4 spaces!

    http://www.FreeRTOS.org - Documentation, latest information, license and
    contact details.

    http://www.SafeRTOS.com - A version that is certified for use in safety
    critical systems.

    http://www.OpenRTOS.com - Commercial support, development, porting,
    licensing and training services.
*/

/******************************************************************************
 * File:     portmacro.h                                                      *
 * Author:   Bianco Zandbergen  (bianco [at] zandbergen [dot] name)           *
 * Changes:  12 feb 2010, initial release                                     *
 *                                                                            *
 * XMOS Platform specific macro's                                             *
 *                                                                            *
 ******************************************************************************/

#ifndef PORTMACRO_H
#define PORTMACRO_H

#define portBYTE_ALIGNMENT 			4

/* kernel stack size in 32-bit words
 * Changing this value needs port_asm.S init_system_ function
 * modification.
 */
#define KSTACK_SIZE					16

/* type definitions */
#define portCHAR					char
#define portFLOAT					float
#define portDOUBLE					double
#define portLONG					long
#define portSHORT					short
#define portSTACK_TYPE				portLONG
#define portBASE_TYPE				portLONG

#if( configUSE_16_BIT_TICKS == 1 )
	typedef unsigned portSHORT portTickType;
	#define portMAX_DELAY ( portTickType ) 0xffff
#else
	typedef unsigned portLONG portTickType;
	#define portMAX_DELAY ( portTickType ) 0xffffffff
#endif

/* architecture specific */
#define portSTACK_GROWTH			( -1 )
#define portTICK_RATE_MS			( ( portTickType ) 1000 / configTICK_RATE_HZ )
#define portNOP()					asm("nop")
#define TIMER_HZ					100000000

/* critical section management */
#define portDISABLE_INTERRUPTS()	asm("clrsr 0x02")
#define portENABLE_INTERRUPTS()		asm("setsr 0x02")
#define portENTER_CRITICAL()		portDISABLE_INTERRUPTS()
#define portEXIT_CRITICAL()			portENABLE_INTERRUPTS()

/* kernel utilities */
#define portYIELD()					asm("kcall 0")

/* Task function macros as described on the FreeRTOS.org WEB site. */
#define portTASK_FUNCTION_PROTO( vFunction, pvParameters ) void vFunction( void *pvParameters )
#define portTASK_FUNCTION( vFunction, pvParameters ) void vFunction( void *pvParameters )

#endif /* PORTMACRO_H */

