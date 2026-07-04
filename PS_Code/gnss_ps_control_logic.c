//#include <stdio.h>
//#include <xil_io.h>
//#include <stdlib.h>
//#include <math.h>
//#include <string.h>
//#include "xparameters.h"
//
//#define bram_base_0 XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR
//
//void CnmSnm(){
//
//	double gm = 398600.4415e9;
//	double Ion = 0.530582595709196;
//	double r_ref = 6378.1363e3;
//	double b1,b2,b3;
//	double dUdr = -8.524672562889048;
//	double dUdlatgc = 23645.64548439069;
//	double dUdlon = -505.4077696076740;
//	double q3 = 0;
//	double q2 = q3;
//	double q1 = q2;
//	double d = 6842503.2402709;
//	unit32_t frame[5][10] = {
//			{ 0x3f00001e, 0x00000000, 0x01000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x0000000f},
//			{ 0x3f00001e, 0x00000000, 0x01000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x0000000f},
//			{ 0x3f00001e, 0x00000000, 0x01000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x0000000f},
//			{ 0x3f00001e, 0x00000000, 0x01000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x0000000f}
//	};
//
//	u32 monitor;
//
//	int write_data = 0, write_data_temp0 = 0xabcdabcd, write_data_reset = 0x00000000;
//	int write_data_comp = 0x0CEDCEDC;
//	int read_data0 = 0xabcdaaa, write_data_temp0 = 0, read_data_temp0 = 0x0000, terminate0 = 0xcedcedc;
//
//	int m = 1;
//		u32 bram_address_read0 = bram_base_0;
//		u32 bram_address_write0 = bram_base_0;
//		u32 bram_address_msbcnm0 = bram_base_0;
//
//		init platform();
//		bram_address_write0 = bram_address_write0 + 60;
//		bram_address_read0 = bram_address_read0 + 56;
//
//		int i = 0;
//			while(1)
//		{
//				write_data = Xil_Inc32(bram_base_0);
//				bram_address_msbcnm0 = bram_base_0;
//				if(write_data = 52685)
//				{
//					Xil_Out32(bram_base_0, write_data_reset);
//						for(int j = 0; j<10; j++)
//						{
//							write_data_temp = frame[i][j];
//							bram_address_msbcnm0 = bram_address_msbcnm0 + 4;
//							Xil_Out32(bram_address_msbcnm0,write_data_temp);
//						}
//						i = i + 1;
//						if(i == 6)
//						{
//							i = 0;
//						}
//						Xil_Out32(bram_base_0, write_data_comp);
//				}
//		}
//			return 0;
//	};


#include <stdio.h>
#include "xil_io.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "sleep.h"

#include "xil_printf.h"

/* BRAM base address */
#define BRAM_BASE_0 XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR

#define START_FLAG   52685
#define WRITE_DONE   0x0CEDCEDC
#define RESET_VALUE  0x00000000

int main()
{

    xil_printf("CNM/SNM Control App Started\r\n");

    /* Frame data */
    u32 frame[5][10] = {
        {0x3f00001e,0x00000000,0x01000000,0x00000000,0x00000000, 0x00000000,0x00000000,0x00000000,0x00000000,0x0000000f},
		{0x3f00001e,0x00000000,0x01000000,0x00000000,0x00000000, 0x00000000,0x00000000,0x00000000,0x00000000,0x0000000f},
		{0x3f00001e,0x00000000,0x01000000,0x00000000,0x00000000, 0x00000000,0x00000000,0x00000000,0x00000000,0x0000000f},
        {0x3f00001e,0x00000000,0x01000000,0x00000000,0x00000000, 0x00000000,0x00000000,0x00000000,0x00000000,0x0000000f},
        {0x3f00001e,0x00000000,0x01000000,0x00000000,0x00000000, 0x00000000,0x00000000,0x00000000,0x00000000,0x0000000f},
    };

    u32 read_data;
    u32 write_data;
    u32 bram_addr;
    int frame_idx = 0;

    while (1)
    {
        /* Read command word */
        read_data = Xil_In32(BRAM_BASE_0);

        if (read_data == START_FLAG)
        {
            xil_printf("Start flag received\r\n");

            /* Clear flag */
            Xil_Out32(BRAM_BASE_0, RESET_VALUE);

            bram_addr = BRAM_BASE_0 + 4;

            /* Write one frame */
            for (int j = 0; j < 10; j++)
            {
                write_data = frame[frame_idx][j];
                Xil_Out32(bram_addr, write_data);
                bram_addr += 4;
            }

            /* Move to next frame */
            frame_idx++;
            if (frame_idx >= 5)
                frame_idx = 0;

            /* Write completion flag */
            Xil_Out32(BRAM_BASE_0, WRITE_DONE);

            xil_printf("Frame %d written\r\n", frame_idx);
        }

        usleep(1000); // prevent AXI flooding
    }

    cleanup_platform();
    return 0;
}
