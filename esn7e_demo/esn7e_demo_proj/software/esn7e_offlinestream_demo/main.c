#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_fifo_util.h"


#define ALMOST_EMPTYFULL_OFFSET 4
#define BUF_SIZE 8192


int main()
{
	int i;

	// initialise esn output fifo
	i = altera_avalon_fifo_init(
			ESN_DOUT_FIFO_OUT_CSR_BASE,
			0, // disable interrupts,
			4, // almost empty level
			2048 - 4); // almost full level

	// read data and channel information from the FIFOs

	IOWR_ALTERA_AVALON_PIO_DATA(LED_BASE,0x00);
	i=0;
	int data[BUF_SIZE];
	for(i= 0; i < BUF_SIZE; i++)
	{
		data[i] = altera_avalon_fifo_read_fifo(
				ESN_DOUT_FIFO_OUT_BASE,
				ESN_DOUT_FIFO_OUT_CSR_BASE);

		// Slow LED FIFO status update
		if (!((i+1)%1000)) {
			IOWR_ALTERA_AVALON_PIO_DATA(LED_BASE,
					(altera_avalon_fifo_read_status(ESN_DOUT_FIFO_OUT_CSR_BASE,0x3f)
							+ (altera_avalon_fifo_read_event(ESN_DOUT_FIFO_OUT_CSR_BASE,0x10) << 2)
							+ (altera_avalon_fifo_read_event(ESN_DOUT_FIFO_OUT_CSR_BASE,0x20) << 3)) & 0xff);
		}

	}

	// Readback data to host
	for (i = 0; i < BUF_SIZE; i++) {
		// MSBs
		int printw;
		if ((data[i] & 0x80000000)>>31) {
			printw = ((data[i] & 0xffff0000)>>16) | 0xffff0000;
		}
		else {
			printw = ((data[i] & 0xffff0000)>>16);
		}
		printf("0:%d\n", printw);
		usleep(250);

		// LSBs
		if ((data[i] & 0x00008000)>>15) {
			printw = ((data[i] & 0x0000ffff)) | 0xffff0000;
		}
		else {
			printw = ((data[i] & 0x0000ffff));
		}
		printf("1:%d\n", printw);
		usleep(250);

	}

	return 0;
}
