#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <math.h>

int main(int argc, char** argv) {
  int c;
  int c_old;
  char buf[60];
  int count = 0;
  int64_t readval;
  double scaleval;


  while ((c=fgetc(stdin))!=EOF) {
    if (c==':') {
      putchar(c);
      if (c_old=='0') {
        // Input integer is from U bus
        while((c=fgetc(stdin))!='\n') {
          if (c==EOF) {exit(-1);}
          buf[count] = c;
          count = count+1;
        }
        buf[count]='\0';
        count = count+1;
        readval = atoi(buf);
        scaleval = (double)readval*pow(2,-12);
        printf("%f\n",scaleval); // print 0: stream as scaled orig.
        scaleval = pow(scaleval,3);
        printf("2:%f\n",scaleval);
        
      }
      else if (c_old=='1') {
        // Input integer is from yhat bus
        while((c=fgetc(stdin))!='\n') {
          if (c==EOF) {exit(-1);}
          buf[count] = c;
          count = count+1;
        }
        buf[count]='\0';
        count=count+1;
        readval = atoi(buf);
        scaleval = (double)pow(2,-11)*readval;
        printf("%f\n",scaleval);
      }
    }
    else {
      // stream identifier or invalid instream
      putchar(c);
    }

    c_old = c;
    count=0;
  }

  return 0;

}
