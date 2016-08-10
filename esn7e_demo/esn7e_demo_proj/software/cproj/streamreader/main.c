#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include "defs.h"

#define IN_FIFO_SIZE 32768
#define JTAG_WORDSEP_CODE 0xc3

static uint16_t* fifo_datain_u_s0;
static uint16_t* fifo_datain_u_s1;
static uint16_t* fifo_datain_yhat_s0; // input data buffer
static uint16_t* fifo_datain_yhat_s1; // input data buffer
static uint16_t* fifo_plot_data_u;
static uint16_t* fifo_plot_data_yhat;
static uint32_t* d_ptr;        // input data pointer
static uint8_t* buf_rd_sector; // sector for output pipe to read from
pthread_mutex_t data0_mutex;
pthread_mutex_t data1_mutex;
//pthread_mutex_t buf_rd_sector_mutex;

void init_mem(void) {
  fifo_datain_yhat_s0 = malloc(IN_FIFO_SIZE*sizeof(int16_t));
  fifo_datain_yhat_s1 = malloc(IN_FIFO_SIZE*sizeof(int16_t));
  fifo_datain_u_s0 = malloc(IN_FIFO_SIZE*sizeof(int16_t));
  fifo_datain_u_s1 = malloc(IN_FIFO_SIZE*sizeof(int16_t));
  fifo_plot_data_u = malloc(IN_FIFO_SIZE*sizeof(int16_t));
  fifo_plot_data_yhat = malloc(IN_FIFO_SIZE*sizeof(int16_t));
  d_ptr = malloc(sizeof(uint32_t));
  buf_rd_sector = malloc(sizeof(uint8_t));

  if (fifo_datain_yhat_s0 == NULL) {
    printf("Failed to allocate buffer memory for predicted outputs 0.\n");
    exit(-1);
  }
  if (fifo_datain_yhat_s1 == NULL) {
    printf("Failed to allocate buffer memory for predicted outputs 1.\n");
    exit(-1);
  }
  if (fifo_plot_data_yhat == NULL) {
    printf("Failed to allocate buffer memory for predicted outputs plot data.\n");
    exit(-1);
  }
  if (fifo_datain_u_s0 == NULL) {
    printf("Failed to allocate buffer memory for inputs 0.\n");
    exit(-1);
  }
  if (fifo_datain_u_s1 == NULL) {
    printf("Failed to allocate buffer memory for inputs 1.\n");
    exit(-1);
  }
  if (fifo_plot_data_u == NULL) {
    printf("Failed to allocate buffer memory for inputs plot data.\n");
    exit(-1);
  }

  if (d_ptr == NULL) {
    printf("Failed to allocate data pointer memory.\n");
    exit(-1);
  }


  if (buf_rd_sector == NULL) {
    printf("Failed to allocate buffer read sector memory.\n");
    exit(-1);
  }

  *d_ptr = 1;
  *buf_rd_sector = 1;

  return;
}

void destroy_mem(void) {
  free(fifo_datain_yhat_s0);
  free(fifo_datain_yhat_s1);
  free(fifo_datain_u_s0);
  free(fifo_datain_u_s1);
  free(fifo_plot_data_u);
  free(fifo_plot_data_yhat);
  free(d_ptr);
  free(buf_rd_sector);

  return;
}

void *reader_thread(void* param) {
  int c;
  int16_t word_accumulator = 0;
  uint8_t word_counter = 0;
  bool got_wordsep = false;
  bool in_frame = false;
  while ((c=fgetc(stdin))!=EOF) {
  //while ((c=fgetc(stdin))) {
    printf("%02x\n", c);
    got_wordsep = (c == (int)JTAG_WORDSEP_CODE);

    if (!got_wordsep && !in_frame) {
      // Initial state -- only accessible from startup
      // Nothing to do. Seek frame alignment
      //printf("Seeking frame alignment...\n");
      continue;
    }

    else if (got_wordsep && !in_frame) {
      // Initial state -- only accessible from startup
      // Got frame alignment: a frame starts on the next character.
      // Set flag for in_frame and clear flag for wordsep
      //printf("Got frame alignment from init.\n");
      in_frame = true;
      word_counter = 0;

    }

    else if (!got_wordsep && in_frame) {
      // In the middle of a frame, and we ate data into c
      // Accumulate temp registers and keep processing the frame
      if (word_counter % 2) {
        // Second word in the 16 bit data
        unsigned int c_sign = (c >> 7) & 0x01;
        c = c | (c_sign << 8);
        word_accumulator = word_accumulator + (c << 7);
        if ((word_counter % 4) / 2) {
          // Write to buf1 (yhat buffer)
          if (*buf_rd_sector == 1) {
            pthread_mutex_lock(&data0_mutex);
            fifo_datain_yhat_s0[*d_ptr-1] = word_accumulator;
            pthread_mutex_unlock(&data0_mutex);
            //printf("Writing data word to yhat buffer sector 0.\n");
          }
          else {
            pthread_mutex_lock(&data1_mutex);
            fifo_datain_yhat_s1[*d_ptr-1] = word_accumulator;
            pthread_mutex_unlock(&data1_mutex);
            //printf("Writing data word to yhat buffer sector 1.\n");
          }
          *d_ptr = *d_ptr+1;

        }
        else {
          // Write to buf0 (U buffer)
          if (*buf_rd_sector == 1) {
            pthread_mutex_lock(&data0_mutex);
            fifo_datain_u_s0[*d_ptr-1] = word_accumulator;
            pthread_mutex_unlock(&data0_mutex);
            //printf("Writing data word to u buffer sector 0.\n");
          }
          else {
            pthread_mutex_lock(&data1_mutex);
            fifo_datain_u_s1[*d_ptr-1] = word_accumulator;
            pthread_mutex_unlock(&data1_mutex);
            //printf("Writing data word to u buffer sector 1.\n");
          }
        }

        word_counter = word_counter+1;
        word_accumulator = 0;

      }
      else {
        // First word in the 16 bit data
        word_accumulator = word_accumulator + c;
        word_counter = word_counter+1;
      }

    }

    else { // (got_wordsep && in_frame)
      // Found the end of the frame. Clear word write data, but stay in in_frame
      // mode assuming the next character is not wordsep. If it is wordsep, then
      // we will stay locked in this state until it is not
      //in_frame = false;
      word_counter = 0;
      //printf("Reached end of frame.\n");

    }

    // Check if buffer is full
    if (!(*d_ptr % IN_FIFO_SIZE)) {
      // Filled one sector of the buffers. Start a child thread to copy and plot
      // Update read location
      if (*buf_rd_sector == 1) {
        *buf_rd_sector = 0;
      }
      else {
        *buf_rd_sector = 1;
      }
      pthread_t copy_worker;
      pthread_create(&copy_worker, NULL, copy_plot_thread, NULL);
      *d_ptr = 1;
    }
    
  }
  printf("Got eof, exiting, errflag %d, eof %d\n",ferror(stdin),feof(stdin));
  // when this loop exits, we are done, so clean up
  destroy_mem();

  pthread_exit(NULL);
}

void *copy_plot_thread(void* param) {
  if (*buf_rd_sector==0) {
    printf("Copying data sector 0 to plot buffer.\n");
    pthread_mutex_lock(&data0_mutex);
    memcpy(fifo_plot_data_u,fifo_datain_u_s0,IN_FIFO_SIZE*sizeof(int16_t));
    memcpy(fifo_plot_data_yhat,fifo_datain_yhat_s0,IN_FIFO_SIZE*sizeof(int16_t));
    pthread_mutex_unlock(&data0_mutex);
    printf("Copied data sector 0 to plot buffer.\n");
  }
  else {
    printf("Copying data sector 1 to plot buffer.\n");
    pthread_mutex_lock(&data1_mutex);
    memcpy(fifo_plot_data_u,fifo_datain_u_s1,IN_FIFO_SIZE*sizeof(int16_t));
    memcpy(fifo_plot_data_yhat,fifo_datain_yhat_s1,IN_FIFO_SIZE*sizeof(int16_t));
    pthread_mutex_unlock(&data1_mutex);
    printf("Copied data sector 1 to plot buffer.\n");
  }

  pthread_exit(NULL);
}

int main(int argc, char *argv[]) {
  pthread_t thread_instream_rd;
  int success;

  init_mem();
  success = pthread_create(&thread_instream_rd, NULL, reader_thread, NULL);
  if (success) {
    printf("ERROR: return code from pthread_create() is %d\n", success);
    exit(-1);
  }

  pthread_exit(NULL);
}
