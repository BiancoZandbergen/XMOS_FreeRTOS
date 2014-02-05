/*
    FreeRTOS V7.6.0 - Copyright (C) 2013 Real Time Engineers Ltd. 
    All rights reserved

    VISIT http://www.FreeRTOS.org TO ENSURE YOU ARE USING THE LATEST VERSION.

    ***************************************************************************
     *                                                                       *
     *    FreeRTOS provides completely free yet professionally developed,    *
     *    robust, strictly quality controlled, supported, and cross          *
     *    platform software that has become a de facto standard.             *
     *                                                                       *
     *    Help yourself get started quickly and support the FreeRTOS         *
     *    project by purchasing a FreeRTOS tutorial book, reference          *
     *    manual, or both from: http://www.FreeRTOS.org/Documentation        *
     *                                                                       *
     *    Thank you!                                                         *
     *                                                                       *
    ***************************************************************************

    This file is part of the FreeRTOS distribution.

    FreeRTOS is free software; you can redistribute it and/or modify it under
    the terms of the GNU General Public License (version 2) as published by the
    Free Software Foundation >>!AND MODIFIED BY!<< the FreeRTOS exception.

    >>! NOTE: The modification to the GPL is included to allow you to distribute
    >>! a combined work that includes FreeRTOS without being obliged to provide
    >>! the source code for proprietary components outside of the FreeRTOS
    >>! kernel.

    FreeRTOS is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  Full license text is available from the following
    link: http://www.freertos.org/a00114.html

    1 tab == 4 spaces!

    ***************************************************************************
     *                                                                       *
     *    Having a problem?  Start by reading the FAQ "My application does   *
     *    not run, what could be wrong?"                                     *
     *                                                                       *
     *    http://www.FreeRTOS.org/FAQHelp.html                               *
     *                                                                       *
    ***************************************************************************

    http://www.FreeRTOS.org - Documentation, books, training, latest versions,
    license and Real Time Engineers Ltd. contact details.

    http://www.FreeRTOS.org/plus - A selection of FreeRTOS ecosystem products,
    including FreeRTOS+Trace - an indispensable productivity tool, a DOS
    compatible FAT file system, and our tiny thread aware UDP/IP stack.

    http://www.OpenRTOS.com - Real Time Engineers ltd license FreeRTOS to High
    Integrity Systems to sell under the OpenRTOS brand.  Low cost OpenRTOS
    licenses offer ticketed support, indemnification and middleware.

    http://www.SafeRTOS.com - High Integrity Systems also provide a safety
    engineered and independently SIL3 certified version for use in safety and
    mission critical applications that require provable dependability.

    1 tab == 4 spaces!
*/

/******************************************************************************
 * File:     port_asm.S                                                       *
 * Author:   Bianco Zandbergen  (bianco [at] zandbergen [dot] name)           *
 * Changes:  12 feb 2010, initial release                                     *
 *           5  feb 2014, updated kernel stack init for increased size        *
 *                                                                            *
 * Lowest level parts of the FreeRTOS XMOS XS1 port.                          *
 * Contains the following:                                                    *
 *                                                                            *
 *     - Macro: SAVE_CONTEXT                                                  *
 *     - Macro: RESTORE_CONTEXT                                               *
 *     - Routine: clock_int_ (clock interrupt handler)                        *
 *     - Routine: init_system_ (init clock, kep and ksp)                      *
 *     - Routine: restore_context_                                            *
 *     - Routine: pxPortInitialiseStack                                       *
 *     - Routine: KERNEL                                                      *
 ******************************************************************************/
 
#include <xs1.h>

/******************************************************************************
 * Macro:        SAVE_CONTEXT                                                 *
 *                                                                            *
 *               Save the context of the current runnig process on            *
 *               the stack of that process. The top word of the stack is      *
 *               not used. Note: it might be possible to use the first        *
 *               stack word (sp[0]) decreasing the context stack frame to     *
 *               19 stack words.                                              *
 ******************************************************************************/
#define SAVE_CONTEXT                                                                                     \
    extsp 20;             /* make room on stack to save context */                                       \
    stw   spc,    sp[1];  /* save the saved program counter register (must be sp[1]!) */                 \
    stw   ssr,    sp[2];  /* save the saved status register (must be sp[2]!) */                          \
    stw   sed,    sp[3];  /* save the saved exception data register (must be sp[3]!) */                  \
    stw   et,     sp[4];  /* save the event type register (must be sp[4]!) */                            \
    stw   dp,     sp[5];  /* save the data pointer */                                                    \
    stw   cp,     sp[6];  /* save the constant pool pointer */                                           \
    stw   lr,     sp[7];  /* save the link register */                                                   \
    stw   r0,     sp[8];  /* save the general purpose registers r0-r11 */                                \
    stw   r1,     sp[9];                                                                                 \
    stw   r2,     sp[10];                                                                                \
    stw   r3,     sp[11];                                                                                \
    stw   r4,     sp[12];                                                                                \
    stw   r5,     sp[13];                                                                                \
    stw   r6,     sp[14];                                                                                \
    stw   r7,     sp[15];                                                                                \
    stw   r8,     sp[16];                                                                                \
    stw   r9,     sp[17];                                                                                \
    stw   r10,    sp[18];                                                                                \
    stw   r11,    sp[19];                                                                                \
    ldaw  r10,    sp[0];            /* get value of current stackpointer */                              \
    ldw   r11,    dp[pxCurrentTCB]; /* pxCurrentTCB holds pointer to TCB of process, store it in r11 */  \
    stw   r10,    r11[0]            /* save current stackpointer to TCB of process */

/********************************************************************************
 * Macro:        RESTORE_CONTEXT                                                *
 *                                                                              *
 *               Restore the process at which pxCurrentTCB points.              *
 *               Only a kret instruction is needed after executing this macro   *
 *               to resume execution of this process.                           *
 ********************************************************************************/
#define RESTORE_CONTEXT                                                                                  \
    ldw   r11,   dp[pxCurrentTCB]; /* get pointer to current TCB */                                      \
    ldw   r11,   r11[0];           /* get the SP from the current TCB */                                 \
    set   sp,    r11;              /* set the SP to the SP of the process we are restoring */            \
    ldw   spc,   sp[1];            /* restore saved program counter */                                   \
    ldw   ssr,   sp[2];            /* restore saved status register */                                   \
    ldw   sed,   sp[3];            /* restore saved exception data */                                    \
    ldw   et,    sp[4];            /* restore exception type */                                          \
    ldw   dp,    sp[5];            /* restore data pointer */                                            \
    ldw   cp,    sp[6];            /* restore constant pool pointer */                                   \
    ldw   lr,    sp[7];            /* restore link register */                                           \
    ldw   r0,    sp[8];            /* restore GP registers r0-r9 */                                      \
    ldw   r1,    sp[9];                                                                                  \
    ldw   r2,    sp[10];                                                                                 \
    ldw   r3,    sp[11];                                                                                 \
    ldw   r4,    sp[12];                                                                                 \
    ldw   r5,    sp[13];                                                                                 \
    ldw   r6,    sp[14];                                                                                 \
    ldw   r7,    sp[15];                                                                                 \
    ldw   r8,    sp[16];                                                                                 \
    ldw   r9,    sp[17];                                                                                 \
    ldc   r10,   80;               /* we are going to decrement stack pointer with 20 words */           \
    add   r11,   r11,     r10;     /* r11 holds the SP, add 80 to it */                                  \
    set   sp,    r11;              /* set the new SP */                                                  \
    sub   r11,   r11,     8;       /* find the position of r10 relative to the new stack pointer */      \
    ldw   r10,   r11[0];           /* restore r10 */                                                     \
    ldw   r11,   r11[1]            /* restore r11 */

/******************************************************************************
 * Function:     clock_int_                                                   *
 * Parameters:   none                                                         *
 * return:       void                                                         *
 *                                                                            *
 *               Clock interrupt handler.                                     *
 *               1. Saves the context of the current running process.         *
 *               2. Set up the timer for the next interrupt.                  *
 *               3. Increment tick and check for expired delays.              *
 *               4. Check which process to run next.                          *
 *               5. Restore context of the next running process               *
 ******************************************************************************/
.globl clock_int_.nstackwords
.globl clock_int_.maxthreads
.globl clock_int_.maxtimers
.globl clock_int_.maxchanends
.linkset clock_int_.nstackwords, 0
.linkset clock_int_.maxthreads,  0
.linkset clock_int_.maxtimers,   0
.linkset clock_int_.maxchanends, 0

.globl clock_int_
.text

clock_int_:

    SAVE_CONTEXT            // save context of current running process

    /* Set up the timer for the next interrupt
       The time of the current interrupt is
       saved in next_int. We add the value of
       1 tick to it and save it in the data
       register of the timer and in next_int.
       This is done because the time at which
       the timer interrupt happened is not
       automatically saved by the processor */

    ldw    r1,         dp[tickclock]       // get timer resource
    ldw    r2,         dp[next_int]        // get timer value of current interrupt
    ldw    r3,         cp[timertick]       // save value to add to the time at which the interrupt happened 
    add    r2,         r2,             r3  // calculate the time for the next interrupt
    setd   res[r1],    r2                  // set up the timer value for the next interrupt
    stw    r2,         dp[next_int]        // store this value in next_int
    
    kentsp 1                // switch over to kernel stack pointer, saving the current SP

    bl xTaskIncrementTick   // increment tick and check for expired delays
    bl vTaskSwitchContext   // choose which process to run next

    krestsp 1               // return from kernel stack pointer, restoring saved SP

    RESTORE_CONTEXT         // restore the context of the next running process

    kret                    // handle over the processor to the restored process

/******************************************************************************
 * Function:     init_system_                                                 *
 * Parameters:   none                                                         *
 * return:       void                                                         *
 *                                                                            *
 *               Initialise some low level parts of the system:               *
 *               1. Set up the timer to generate interrupts.                  *
 *               2. Set up the kernel entry point.                            *
 *               3. Set up the kernel stack pointer.                          *
 ******************************************************************************/
.extern init_system_
.globl init_system_.nstackwords
.globl init_system_.maxthreads
.globl init_system_.maxtimers
.globl init_system_.maxchanends
.linkset init_system_.nstackwords, 0
.linkset init_system_.maxthreads,  0
.linkset init_system_.maxtimers,   0
.linkset init_system_.maxchanends, 0
.globl init_system_

.cc_top init_system_.func, init_system_

init_system_:
 
    // setup tick timer
    ldap    r11,        clock_int_                   // get address of interrupt handler
    ldw     r1,         dp[tickclock]                // get timer resource handler
    setv    res[r1],    r11                          // set the interrupt vector of the timer
    setc    res[r1],    XS1_SETC_IE_MODE_INTERRUPT   // set timer in interrupt mode
    setc    res[r1],    XS1_SETC_COND_AFTER          // generate interrupt if timer value > timer data register
    in      r0,         res[r1]                      // get current timer value
    ldw     r2,         cp[timertick]                // load timer cycles of one tick to r2
    add     r0,         r0,              r2          // add timer cycles of one tick to current timer value
    setd    res[r1],    r0                           // save the timer value of next interrupt in data register of timer
    stw     r0,         dp[next_int]                 // store this value also in next_int
    eeu     res[r1]                                  // enable events and interrupts from timer

    // set kernel entry point
    ldap    r11,        kep
    set     kep,        r11
    
    // setup kernel stack
    ldaw    r0,         sp[0]                 // save current SP to r0
    ldaw    r2,         dp[kstack]            // Get address of bottom of stack
    ldc     r3,         124                    // offset from end of stack, must be (KSTACK_SIZE-1)*4
    add     r2,         r3,              r2   // Get top of stack
    set     sp,         r2                    // Set SP to KSP address
    krestsp 0                                 // set KSP
    set     sp,         r0                    // restore SP
    
    setsr   0x02  // set status register to enable interrupts
                  // If using XGDB and breakpoints before starting the scheduler
                  // enable interrupts at restore_context_ before the kret instruction.
    retsp   0

.cc_bottom init_system_.func

/******************************************************************************
 * Function:     restore_context_                                             *
 * Parameters:   none                                                         *
 * return:       void, handles over the processor to the restored process     *
 *                                                                            *
 *               Restores the context and handles over the processor of the   *
 *               process pointed by pxCurrentTCB.                             *
 *               Used to start the scheduler.                                 *
 ******************************************************************************/
.extern restore_context_
.globl restore_context_.nstackwords
.globl restore_context_.maxthreads
.globl restore_context_.maxtimers
.globl restore_context_.maxchanends
.linkset restore_context_.nstackwords, 0
.linkset restore_context_.maxthreads,  0
.linkset restore_context_.maxtimers,   0
.linkset restore_context_.maxchanends, 0
.globl restore_context_

.cc_top restore_context_.func, restore_context_

restore_context_:

    RESTORE_CONTEXT   // restore process contexti
    kret              // handle over the processor to that process

.cc_bottom restore_context_.func

/******************************************************************************
 * Function:     pxPortInitialiseStack                                        *
 * Parameters:   r0 - pointer to stack to initialise                          *
 *               r1 - pointer to task code                                    *
 *               r2 - pointer to parameters for task                          *
 * return:       value of stackpointer of process after initialisation        *
 *                                                                            *
 *               Initialises the stack of a newly created process so that it  *
 *               is as if it were running. A context switch by the scheduler  *
 *               will start the process.                                      *
 ******************************************************************************/
.extern pxPortInitialiseStack
.globl pxPortInitialiseStack.nstackwords
.globl pxPortInitialiseStack.maxthreads
.globl pxPortInitialiseStack.maxtimers
.globl pxPortInitialiseStack.maxchanends
.linkset pxPortInitialiseStack.nstackwords, 0
.linkset pxPortInitialiseStack.maxthreads,  0
.linkset pxPortInitialiseStack.maxtimers,   0
.linkset pxPortInitialiseStack.maxchanends, 0

.cc_top pxPortInitialiseStack.func, pxPortInitialiseStack
.globl  pxPortInitialiseStack,"f{p(sl)}(p(sl),p(f{0}(p(0))),p(0))"

pxPortInitialiseStack:
    ldaw      r3,       sp[0]    // save current SP to r3, need to restore SP when leaving function
    set       sp,       r0       // set current SP to the first parameter
    extsp     22                 // extend stack

    stw       r1,       sp[1]    // save pointer to task on stack
    
    ldc       r0,       0x02     // save status register on stack, 0x02 = enable interrupts
    stw       r0,       sp[2]     

    stw       sed,      sp[3]    // save saved exception data on stack, inherit from calling process
    stw       et,       sp[4]    // save exception type on stack, inherit from calling process

    ldaw      r0,       dp[0]    // save data pointer on stack, inherit from calling process
    stw       r0,       sp[5]
    
    ldaw      r11,      cp[0]    // save constant pointer on stack, inherit from calling process
    stw       r11,      sp[6]

    ldc       r0,       0        // save link register on stack, init with 0
    stw       r0,       sp[7]

    stw       r2,       sp[8]    // register r0 - pointer to parameters (r2)

    ldc       r0,       1        // r1
    stw       r0,       sp[9]
    
    ldc       r0,       2        // r2
    stw       r0,       sp[10]   

    ldc       r0,       3        // r3
    stw       r0,       sp[11]

    ldc       r0,       4        // r4
    stw       r0,       sp[12]

    ldc       r0,       5        // r5
    stw       r0,       sp[13]

    ldc       r0,       6        // r6
    stw       r0,       sp[14]

    ldc       r0,       7        // r7
    stw       r0,       sp[15]

    ldc       r0,       8        // r8
    stw       r0,       sp[16]

    ldc       r0,       9        // r9
    stw       r0,       sp[17]

    ldc       r0,       10       // r10
    stw       r0,       sp[18]

    ldc       r0,       11       // r11
    stw       r0,       sp[19]

    ldc       r0,       0xdead   // two test values at the start of the stack for debugging
    stw       r0,       sp[20]
    
    ldc       r0,       0xbabe
    stw       r0,       sp[21]

    ldaw      r0,       sp[0]    // address at which the SP points as return value
    
    set       sp,       r3       // restore stack pointer to calling process

    retsp     0
    
.cc_bottom pxPortInitialiseStack.func

/******************************************************************************
 * KERNEL ENTRY POINT                                                         *
 *                                                                            *
 * Exceptions jump to the kernel entry point (infinite loop)                  *
 * Kernel calls jump to the kernel entry point + 128 bytes.                   *
 * Currently the only kernel call is to manually switch context,              *
 * the argument passed by the KCALL(I) instruction to the exception data      *
 * register is not checked.                                                   *
 ******************************************************************************/ 
.align 128                   // align the exception section to 128 bytes
kep:                         // entry point for exceptions
    bu kep                   // infinite loop

.align 64                    // kernel must be aligned on 64 bytes
kcall_ep:                    // entry point for kernel calls (switch context)

    SAVE_CONTEXT             // save context of caller process

    ldw r0, sp[1]            // the saved program counter does not contain the next instruction
    ldc r1, 2                // but the address of the KCALL instruction.
    add r0, r0, r1           // Add two to the saved program counter that was saved on the stack
    stw r0, sp[1]            // to jump over the KCALL instruction.

    kentsp 1                 // switch to kernel stack pointer

    bl vTaskSwitchContext    // choose which process to run next

    krestsp 1                // return from kernel stack pointer and restore saved SP

    RESTORE_CONTEXT          // restore context of the next running process
    kret                     // handle over the processor to this process

/* END OF KERNEL */
