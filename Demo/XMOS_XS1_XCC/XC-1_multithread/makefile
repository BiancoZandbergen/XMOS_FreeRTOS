# Makefile for the FreeRTOS XMOS XS1 port
# Works on GNU/Linux and Mac OS X.
# Might need modification on Windows.

# valid options with configured LED output are:
# XC_1, XC_1A, XC_2, XC_5, XK_1, XDK
# Use CUSTOM to specify own target (need to modify ParTest.xc in this case)
#
# Edit: this demo only runs on the XC-1 board without code modification
BOARD=XC_1

# specify target processor here if board is CUSTOM
ifeq ($(BOARD),CUSTOM)
	TARGET=
endif
ifeq ($(BOARD),XC_1)
	TARGET=XS1-G04B-FB512-C4
endif
ifeq ($(BOARD),XC_1A)
	TARGET=XC-1A
endif
ifeq ($(BOARD),XC_2)
	TARGET=XC-2
endif
ifeq ($(BOARD),XC_5)
	TARGET=XC-5
endif
ifeq ($(BOARD),XK_1)
	TARGET=XK-1
endif
ifeq ($(BOARD),XDK)
	TARGET=XDK
endif

# program executable name
PROGRAM=demo.xe

# compiler optimisation
SRC_OPT=-O0

# debug options
DEBUG=-g

SOURCE_DIR=../../../Source
PORT_DIR=../../../Source/portable/XCC/XMOS_XS1
DEMO_DIR=../../Common/Minimal
INCLUDE=-I . -I $(SOURCE_DIR)/include -I $(PORT_DIR)
INCLUDE_COMMON=-I ../../Common/include
CFLAGS= $(DEBUG) -D XCC_XMOS_XS1 -target=$(TARGET)  $(INCLUDE)

REMOVE=rm -f

OBJS=tasks.o queue.o list.o croutine.o heap_3.o port.o port_asm.o port_xc.o \
		main.o ParTest.o par.o

# tests
OBJS+=integer.o BlockQ.o PollQ.o

all: $(PROGRAM)

$(PROGRAM): $(OBJS)
	xcc $(DEBUG) $(CFLAGS)  $(OBJS) -o $(PROGRAM)

tasks.o: $(SOURCE_DIR)/tasks.c FreeRTOSConfig.h
	xcc -c $(SRC_OPT) $(CFLAGS)  $(SOURCE_DIR)/tasks.c

queue.o: $(SOURCE_DIR)/queue.c FreeRTOSConfig.h
	xcc -c $(SRC_OPT) $(CFLAGS) $(SOURCE_DIR)/queue.c

list.o: $(SOURCE_DIR)/list.c FreeRTOSConfig.h
	xcc -c $(SRC_OPT) $(CFLAGS) $(SOURCE_DIR)/list.c

croutine.o: $(SOURCE_DIR)/croutine.c FreeRTOSConfig.h
	xcc -c $(SRC_OPT) $(CFLAGS) $(SOURCE_DIR)/croutine.c

heap_3.o: $(SOURCE_DIR)/portable/MemMang/heap_3.c FreeRTOSConfig.h
	xcc -c $(SRC_OPT) $(CFLAGS) $(SOURCE_DIR)/portable/MemMang/heap_3.c

port.o: $(PORT_DIR)/port.c FreeRTOSConfig.h
	xcc -c $(SRC_OPT) $(CFLAGS) $(PORT_DIR)/port.c

port_asm.o: $(PORT_DIR)/port_asm.S FreeRTOSConfig.h
	xcc -c $(SRC_OPT) $(CFLAGS) $(PORT_DIR)/port_asm.S

port_xc.o: $(PORT_DIR)/port_xc.xc FreeRTOSConfig.h
	xcc -c $(SRC_OPT) $(CFLAGS) $(PORT_DIR)/port_xc.xc

main.o: main.c FreeRTOSConfig.h
	xcc -c $(SRC_OPT) $(CFLAGS) $(INCLUDE_COMMON) main.c

ParTest.o: ParTest/ParTest.xc
	xcc -c $(SRC_OPT) $(CFLAGS) -D BOARD=$(BOARD) ParTest/ParTest.xc

integer.o: $(DEMO_DIR)/integer.c
	xcc -c $(SRC_OPT) $(CFLAGS) $(INCLUDE_COMMON) $(DEMO_DIR)/integer.c

BlockQ.o: QueueTest/BlockQ.c
	xcc -c $(SRC_OPT) $(CFLAGS) QueueTest/BlockQ.c

PollQ.o: QueueTest/PollQ.c
	xcc -c $(SRC_OPT) $(CFLAGS) QueueTest/PollQ.c

par.o: par.xc
	xcc -c $(SRC_OPT) $(CFLAGS) par.xc

clean:
	$(REMOVE) $(OBJS) $(PROGRAM)

run:
	xrun --io $(PROGRAM)

runsim:
	xsim -t $(PROGRAM)
