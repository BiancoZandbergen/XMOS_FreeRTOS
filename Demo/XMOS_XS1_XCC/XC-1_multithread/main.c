/******************************************************************************
 * File:     main.c                                                           *
 * Author:   Bianco Zandbergen  (bianco [at] zandbergen [dot] name)           *
 * Changes:  17 feb 2010, initial release                                     *
 *                                                                            *
 * Simple demo running a integer task and tasks to test blocked and           *
 * polled queues. One or more LED's on the board will blink if nothing goes   *
 * wrong.                                                                     *
 *                                                                            *
 * EDIT: main() has been renamed to start_FreeRTOS() for the parallel test.   *
 * See par.xc                                                                 *
 ******************************************************************************/
#include <stdio.h>
#include "FreeRTOS.h"
#include "task.h"
#include "croutine.h"
#include "queue.h"

/* tests */
#include "integer.h"
#include "QueueTest/BlockQ.h"
#include "QueueTest/PollQ.h"

#define mainMATH_PRIORITY				(tskIDLE_PRIORITY + 1)
#define mainBLOCKED_QUEUE_PRIORITY		(tskIDLE_PRIORITY + 2)
#define mainPOLLED_QUEUE_PRIORITY		(tskIDLE_PRIORITY + 2)
#define mainCHECK_PRIORITY 				(tskIDLE_PRIORITY + 3)

void vCheckTasks();

/* renamed main routine */
int start_FreeRTOS(void)
{
	vParTestInitialise();
	vStartIntegerMathTasks(mainMATH_PRIORITY);
	vStartBlockedQueueTest(mainBLOCKED_QUEUE_PRIORITY);
	vStartPolledQueueTest(mainPOLLED_QUEUE_PRIORITY);
	xTaskCreate(vCheckTasks, (signed char *) "check", 85, NULL, mainCHECK_PRIORITY, NULL);
	vTaskStartScheduler();

	return 0; /* should not reach */
}

/* check if tasks are still running OK.
 * If everything is Ok the LED's will blink on 1HZ.
 * If something is wrong it will not blink.
 */
void vCheckTasks()
{
	#define TEST_ERROR 1
	#define TEST_FINE  0

	int led_state = 0;
	int test_state = TEST_FINE;

	while(1) {
		
		vTaskDelay(500);

		if (test_state == TEST_FINE) {
			if (xAreIntegerMathsTaskStillRunning() != pdTRUE) {
				test_state = TEST_ERROR;
			}

			if (xAreBlockingQueuesStillRunning() != pdTRUE) {
				test_state = TEST_ERROR;
			}

			if (xArePollingQueuesStillRunning() != pdTRUE) {
				test_state = TEST_ERROR;
			}
			
		}

		if (test_state == TEST_FINE) {
			if (led_state) {
				led_state = 0;
				vParTestSetLed((unsigned long)led_state);
			} else {
				led_state = 1;
				vParTestSetLed((unsigned long)led_state);
			}
		}
	}
}

void vApplicationIdleHook(void)
{
	while(1);
}
