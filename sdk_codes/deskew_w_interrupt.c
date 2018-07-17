/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
//#include "printf.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xbasic_types.h"
#include "images.h"
#include "xil_exception.h"
#include "xscugic.h"
#include "xil_cache.h"

#define INTC_DEVICE_ID 		XPAR_PS7_SCUGIC_0_DEVICE_ID
#define DESKEW_INTR_ID		XPAR_FABRIC_DESKEW_0_DONE_INTERRUPT_INTR
#define DESKEW_ID 			XPAR_DESKEW_0_DEVICE_ID

static XScuGic INTCInst;

typedef struct {
	void *CallBackRef;	 /**< Callback reference for handler */
} Deskew_ctr;
void Deskew_interrupt_handler(void *intc_inst_ptr);
u32 Init_Function(u32 DeviceId);
static int intr_data;


int main()
{
	    u32 ready = 0;
		u32 start = 1;
		int status;
		u32 pixel;
	    init_platform();

	    printf("\nDeskew started");
	    status = Init_Function(INTC_DEVICE_ID);

	    u32 dskw_image [784];

	    for(int i = 0; i<784; i++)
	    	Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + i*4, image_arr[i]);
	    Xil_DCacheFlush();
	    for(int i = 0; i< 100; i++);


	    //for(int i = 0; i< 100000; i++);

	    Xil_Out32(XPAR_DESKEW_0_S00_AXI_BASEADDR, 0x1);//start = 1

	    Xil_Out32(XPAR_DESKEW_0_S00_AXI_BASEADDR, 0x0);//start = 0

	    while(intr_data != 5){}
	    intr_data = 0;

		for(int i = 0; i< 100; i++);
//	    for(int i = 0; i<784; i++)
//	    	printf("%d: 0x%08x \t %#010lx \n", i ,(Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + i*4 + 784*4)) ,hdl_dskw_image[i]);

	    //second picture

	    Xil_Out32(XPAR_DESKEW_0_S00_AXI_BASEADDR, 0x1);//start = 1

		Xil_Out32(XPAR_DESKEW_0_S00_AXI_BASEADDR, 0x0);//start = 0

		while(intr_data != 5){}


		for(int i = 0; i< 100; i++);
		printf("\nintr_data is: %d\n", intr_data);
		for(int i = 0; i<784; i++)
			printf("%d: 0x%08x \t %#010x \n", i ,(Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + i*4 + 784*4)) ,hdl_dskw_image[i]);
		printf("\naplication done");
	    cleanup_platform();
	    return 0;
}


u32 Init_Function(u32 DeviceId)
{
	XScuGic_Config *IntcConfig;
	int status;
	IntcConfig = XScuGic_LookupConfig(DeviceId);
	status = XScuGic_CfgInitialize(&INTCInst, IntcConfig, IntcConfig->CpuBaseAddress);
	if(status != XST_SUCCESS) return XST_FAILURE;
	//status = XScuGic_SelfTest(&INTCInst);
//	if (status != XST_SUCCESS)
//	{
//	  return XST_FAILURE;
//	  printf("error");
//	}

	XScuGic_SetPriorityTriggerType(&INTCInst, DESKEW_INTR_ID,0xA0, 3);

	status = XScuGic_Connect(&INTCInst,

						DESKEW_INTR_ID,

					 (Xil_ExceptionHandler)Deskew_interrupt_handler,

					 (void *)&INTCInst);

	if(status != XST_SUCCESS) return XST_FAILURE;




	//XScuGic_InterruptMaptoCpu(&INTCInst, 0, 61);
	XScuGic_Enable(&INTCInst, DESKEW_INTR_ID);
	//Xil_ExceptionEnableMask(XIL_EXCEPTION_ALL);
	//interuptSystemSetup
	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,

						 (Xil_ExceptionHandler)XScuGic_InterruptHandler,

						 &INTCInst);
	Xil_ExceptionEnable();
		////////////////////////////////////////////////////
	return XST_SUCCESS;

}

void Deskew_interrupt_handler(void *intc_inst_ptr)
{
	intr_data = 5;
}
