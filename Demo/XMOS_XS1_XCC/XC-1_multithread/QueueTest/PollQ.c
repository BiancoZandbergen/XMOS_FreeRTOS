#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"


static void pollingProducer(void *arg);
static void pollingConsumer(void *arg);

unsigned long poll_result;
unsigned long prev_poll_result;

void vStartPolledQueueTest(unsigned portBASE_TYPE priority)
{
	xQueueHandle poll_handle;
	poll_handle = xQueueCreate(1, sizeof(unsigned long));
	xTaskCreate(pollingProducer, (signed char *)"cprod", 85, (void *)poll_handle, priority, NULL);
	xTaskCreate(pollingConsumer, (signed char *)"ccons", 85, (void *)poll_handle, priority, NULL);
}

static void pollingProducer(void *arg)
{
	unsigned long sendbuf = 1;

	while (1) {
		xQueueSend((xQueueHandle)arg, &sendbuf, 0);
		sendbuf++;
		vTaskDelay(50);
	}
}

static void pollingConsumer(void *arg)
{
	unsigned long recbuf;

	while (1) {
		if (xQueueReceive((xQueueHandle)arg, &recbuf, 0) == pdTRUE) {
			poll_result = recbuf;
		}
		vTaskDelay(25);
	}
}

portBASE_TYPE xArePollingQueuesStillRunning()
{
	if (poll_result != prev_poll_result) {
		prev_poll_result = poll_result;
		return pdTRUE;
	} else {
		return pdFALSE;
	}
}
