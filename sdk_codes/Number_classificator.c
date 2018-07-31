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
#include "xaxidma.h"
#include "xil_io.h"
#include "xbasic_types.h"
#include "images.h"
#include "xil_exception.h"
#include "xscugic.h"
#include "xil_cache.h"

#include "lt.h"
#include "sv_array.h"
#include "xdebug.h"

#include "input_image.h"
#include "biases.h"

#define DMA_DEV_ID		XPAR_AXIDMA_0_DEVICE_ID

#ifdef XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
#define DDR_BASE_ADDR		XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
#elif XPAR_MIG7SERIES_0_BASEADDR
#define DDR_BASE_ADDR	XPAR_MIG7SERIES_0_BASEADDR
#elif XPAR_MIG_0_BASEADDR
#define DDR_BASE_ADDR	XPAR_MIG_0_BASEADDR
#elif XPAR_PSU_DDR_0_S_AXI_BASEADDR
#define DDR_BASE_ADDR	XPAR_PSU_DDR_0_S_AXI_BASEADDR
#endif

#ifndef DDR_BASE_ADDR
#warning CHECK FOR THE VALID DDR ADDRESS IN XPARAMETERS.H, \
		DEFAULT SET TO 0x01000000
#define MEM_BASE_ADDR		0x01000000
#else
#define MEM_BASE_ADDR		(DDR_BASE_ADDR + 0x1000000)
#endif



#define INTC_DEVICE_ID 		XPAR_PS7_SCUGIC_0_DEVICE_ID
#define DESKEW_ID 			0//XPAR_DESKEW_0_DEVICE_ID
#define DESKEW_INTR_ID		XPAR_FABRIC_DESKEW_0_DONE_INTERRUPT_INTR
#define DESKEW_BASE_ADDR	XPAR_DESKEW_0_BASEADDR

#define SVM_ID 				0//XPAR_SVM_IP_0_DEVICE_ID
#define SVM_INTR_ID 		XPAR_FABRIC_SVM_IP_0_INTERRUPT_INTR
#define SVM_BASE_ADDR		XPAR_SVM_IP_0_BASEADDR

#define TX_INTR_ID			XPAR_FABRIC_AXI_DMA_0_MM2S_INTROUT_INTR
#define TX_BUFFER_BASE		(MEM_BASE_ADDR + 0x00100000)

#define RESET_TIMEOUT_COUNTER	10000
#define IMG_LEN 	784
#define MAX_PKT_LEN (4*784)

void Deskew_interrupt_handler(void *intc_inst_ptr);
void SVM_interrupt_handler(void * intc_inst_ptr);
static void TxIntrHandler(void *Callback);
static void DisableIntrSystem();
static void TxIntrHandler(void *Callback);
u32 Init_Function(u32 DeviceId);
u32 DMA_init();

volatile int dskw_intr_done;
volatile int svm_intr_done;
volatile int Error;
volatile int tx_intr_done;

static XScuGic INTCInst;
static XAxiDma AxiDma;		/* Instance of the XAxiDma */

int main()
{

		int status,image,core,sv,i;
		u32 *TxBufferPtr;
		TxBufferPtr = (u32 *)TX_BUFFER_BASE ;
	    init_platform();
	    unsigned int num_of_sv[10]={361,267,581,632,480,513,376,432,751, 683};
	    u32 dskw_image[784];

	    xil_printf("\r\nStarting simulation");
	    status = Init_Function(INTC_DEVICE_ID);
	    Xil_DCacheDisable();
	    Xil_ICacheDisable();

	    dskw_intr_done = 0;
	    svm_intr_done =0;
	    //image = 0;
	    for(image=0; image <10; image++ )
	    {
			//WRITE TEST IMAGE IN BRAM
			for(i = 0; i<784; i++)
				Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + i*4, y_array[image*784+i]);
			Xil_DCacheFlush();
			for(i = 0; i< 100; i++);



			//START DESKEW
			Xil_Out32(DESKEW_BASE_ADDR, 0x1);//start = 1
			Xil_Out32(DESKEW_BASE_ADDR, 0x0);//start = 0
			//WAIT FOR INTERRUPT (FINISHED)
			while(!dskw_intr_done){}
			dskw_intr_done = 0;
			for(i = 0; i< 100; i++);


			for(i = 0; i<784; i++)
				dskw_image[i] = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + i*4 + 784*4);



			/*for(int i = 0; i< 100; i++);
			printf("\nintr_data is: %d\n", dskw_intr_done);
			for(int i = 0; i<784; i++)
				printf("%d: 0x%08x \t %#010x \n", i ,(Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + i*4 + 784*4)) ,hdl_dskw_image[i]);*/
			// STARTING SVM
			Xil_Out32(SVM_BASE_ADDR, 0x1);//start = 1
			Xil_Out32(SVM_BASE_ADDR, 0x0);//start = 0
			//WAIT FOR INTERRUPT (SEND IMAGE)
			while(!svm_intr_done){}
			svm_intr_done = 0;

			//SEND IMAGE TROUGH DMA
			for(i=0; i<IMG_LEN; i++)
				TxBufferPtr[i] = dskw_image[i];
			Xil_DCacheFlushRange((UINTPTR)TxBufferPtr, MAX_PKT_LEN);
			status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR) TxBufferPtr, MAX_PKT_LEN, XAXIDMA_DMA_TO_DEVICE );
			if(status != XST_SUCCESS)
				return XST_FAILURE;
			//WAIT FOR TX INTERRUPT(DATA SENT)
			while(!tx_intr_done){};


			for(core=0; core<10; core++)
			{
				for(sv=0; sv<num_of_sv[core]; sv++)
				{

					//WAIT FOR SVM INTERRUPT (SEND SV)
					while(!svm_intr_done){}
					svm_intr_done = 0;
					//SEND ONE SUPPORT VECTOR
					for(i=0; i<IMG_LEN; i++)
						TxBufferPtr[i] = sv_array[core][sv*784+i];
					Xil_DCacheFlushRange((UINTPTR)TxBufferPtr, MAX_PKT_LEN);
					status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR) TxBufferPtr, MAX_PKT_LEN, XAXIDMA_DMA_TO_DEVICE );
					if(status != XST_SUCCESS)
						return XST_FAILURE;
					while(!tx_intr_done){};
					//for(i=0; i<50; i++);
					//WAIT FOR SVM INTERRUPT (SEND LAMBDA)
					while(!svm_intr_done){}
					svm_intr_done = 0;
					//SEND LAMBDA
					TxBufferPtr[0] = lt_array[core][sv];
					Xil_DCacheFlushRange((UINTPTR)TxBufferPtr, MAX_PKT_LEN);
					status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR) TxBufferPtr, 4, XAXIDMA_DMA_TO_DEVICE );
					if(status != XST_SUCCESS)
						return XST_FAILURE;
					while(!tx_intr_done){};

				}
				//for(i=0; i<50; i++);
				//WAIT FOR SVM INTERRUPT (SEND BIAS)
				while(!svm_intr_done){}
				svm_intr_done = 0;
				//SEND BIAS
				TxBufferPtr[0] = b_array[core];
				Xil_DCacheFlushRange((UINTPTR)TxBufferPtr, MAX_PKT_LEN);
				status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR) TxBufferPtr, 4, XAXIDMA_DMA_TO_DEVICE );
				if(status != XST_SUCCESS)
					return XST_FAILURE;
				while(!tx_intr_done){}

			}
			//for(i=0; i<500; i++);
			//WAIT FOR SVM INTERRUPT (CLASS. FINISHED)
			while(!svm_intr_done){}
			svm_intr_done = 0;
			xil_printf("\nClassified number: %d, Actual number: %d ",Xil_In32(SVM_BASE_ADDR+8),labels[image]);//start = 1
	    }

	    DisableIntrSystem();
	    cleanup_platform();
	    return 0;
}




void Deskew_interrupt_handler(void *intc_inst_ptr)
{
	dskw_intr_done = 1;
}
void SVM_interrupt_handler(void * intc_inst_ptr)
{
	svm_intr_done = 1;
}

static void TxIntrHandler(void *Callback)
{

	u32 IrqStatus;
	int TimeOut;
	XAxiDma *AxiDmaInst = (XAxiDma *)Callback;

	/* Read pending interrupts */
	IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DMA_TO_DEVICE);

	/* Acknowledge pending interrupts */


	XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DMA_TO_DEVICE);

	/*
	 * If no interrupt is asserted, we do not do anything
	 */
	if (!(IrqStatus & XAXIDMA_IRQ_ALL_MASK)) {

		return;
	}

	/*
	 * If error interrupt is asserted, raise error flag, reset the
	 * hardware to recover from the error, and return with no further
	 * processing.
	 */
	if ((IrqStatus & XAXIDMA_IRQ_ERROR_MASK)) {

		Error = 1;

		/*
		 * Reset should never fail for transmit channel
		 */
		XAxiDma_Reset(AxiDmaInst);

		TimeOut = RESET_TIMEOUT_COUNTER;

		while (TimeOut) {
			if (XAxiDma_ResetIsDone(AxiDmaInst)) {
				break;
			}

			TimeOut -= 1;
		}

		return;
	}

	/*
	 * If Completion interrupt is asserted, then set the tx_intr_done flag
	 */
	if ((IrqStatus & XAXIDMA_IRQ_IOC_MASK)) {

		tx_intr_done = 1;
	}
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
///Deskew interrupt enable and connect
	XScuGic_SetPriorityTriggerType(&INTCInst, DESKEW_INTR_ID,0xA8, 3);

	status = XScuGic_Connect(&INTCInst, DESKEW_INTR_ID, (Xil_ExceptionHandler)Deskew_interrupt_handler, (void *)&INTCInst);

	if(status != XST_SUCCESS) return XST_FAILURE;

	XScuGic_Enable(&INTCInst, DESKEW_INTR_ID);
//*****************************************************
///SVM interrupt enable and connect
	XScuGic_SetPriorityTriggerType(&INTCInst, SVM_INTR_ID,0xA0, 3);

	status = XScuGic_Connect(&INTCInst, SVM_INTR_ID, (Xil_ExceptionHandler)SVM_interrupt_handler, (void *)&INTCInst);

	if(status != XST_SUCCESS) return XST_FAILURE;

	XScuGic_Enable(&INTCInst, SVM_INTR_ID);
//*****************************************************

//DMA enable and connect
	DMA_init();
//*********************************************************

	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,

						 (Xil_ExceptionHandler)XScuGic_InterruptHandler,

						 &INTCInst);
	Xil_ExceptionEnable();
		////////////////////////////////////////////////////
	return XST_SUCCESS;

}


u32 DMA_init()
{
	int Status;
	XAxiDma_Config *Config;


	Config = XAxiDma_LookupConfig(DMA_DEV_ID);
	if (!Config) {
		xil_printf("No config found for %d\r\n", DMA_DEV_ID);

		return XST_FAILURE;
	}

	/* Initialize DMA engine */
	Status = XAxiDma_CfgInitialize(&AxiDma, Config);

	if (Status != XST_SUCCESS) {
		xil_printf("Initialization failed %d\r\n", Status);
		return XST_FAILURE;
	}

	if(XAxiDma_HasSg(&AxiDma)){
		xil_printf("Device configured as SG mode \r\n");
		return XST_FAILURE;
	}

	/* Disable all interrupts before setup */

		XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
							XAXIDMA_DMA_TO_DEVICE);

		XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
					XAXIDMA_DEVICE_TO_DMA);

	/* Set up Interrupt system  */
	XScuGic_SetPriorityTriggerType(&INTCInst, TX_INTR_ID, 0xA8, 0x3);

	/*
	 * Connect the device driver handler that will be called when an
	 * interrupt for the device occurs, the handler defined above performs
	 * the specific interrupt processing for the device.
	 */
	Status = XScuGic_Connect(&INTCInst, TX_INTR_ID, (Xil_InterruptHandler)TxIntrHandler, &AxiDma);
	if (Status != XST_SUCCESS) {
		return Status;
	}



	XScuGic_Enable(&INTCInst, TX_INTR_ID);

	/* Enable all interrupts */
	XAxiDma_IntrEnable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
							XAXIDMA_DMA_TO_DEVICE);


	XAxiDma_IntrEnable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
							XAXIDMA_DEVICE_TO_DMA);

	/* Initialize flags before start transfer test  */
	tx_intr_done = 0;
	Error = 0;
	return 0;
}

static void DisableIntrSystem()
{

	XScuGic_Disconnect(&INTCInst, TX_INTR_ID);
	XScuGic_Disconnect(&INTCInst, SVM_INTR_ID);
	XScuGic_Disconnect(&INTCInst, DESKEW_INTR_ID);

}
