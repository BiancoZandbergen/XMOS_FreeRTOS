#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"


static void blockingProducer(void *arg);
static void blockingConsumer(void *arg);

unsigned long block_result;
unsigned long prev_block_result;

void vStartBlockedQueueTest(unsigned portBASE_TYPE priority)
{
	xQueueHandle block_handle;
	block_handle = xQueueCreate(1, sizeof(unsigned long));
	xTaskCreate(blockingProducer, (signed char *)"bprod", 85, (void *)block_handle, priority, NULL);
	xTaskCreate(blockingConsumer, (signed char *)"bcons", 85, (void *)block_handle, priority, NULL);
}

static void blockingProducer(void *arg)
{
	unsigned long sendbuf = 1;

	while (1) {
		xQueueSend((xQueueHandle)arg, &sendbuf, 10000);
		sendbuf++;
		vTaskDelay(50);
	}
}

static void blockingConsumer(void *arg)
{
	unsigned long recbuf;

	while (1) {
		xQueueReceive((xQueueHandle)arg, &recbuf, 10000);
		block_result = recbuf;
	}
}

portBASE_TYPE xAreBlockingQueuesStillRunning()
{
	if (block_result != prev_block_result) {
		prev_block_result = block_result;
		return pdTRUE;
	} else {
		return pdFALSE;
	}
}
