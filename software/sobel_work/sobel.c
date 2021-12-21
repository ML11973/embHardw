/*
 * sobel.c
 *
 *  Created on: Sep 12, 2015
 *      Author: theo
 */

#include <stdlib.h>
#include <stdio.h>
#include <system.h>
#include "io.h"

#define CI

const char gx_array[3][3] = {{-1,0,1},
                             {-2,0,2},
                             {-1,0,1}};
const char gy_array[3][3] = { {1, 2, 1},
                              {0, 0, 0},
                             {-1,-2,-1}};

short *sobel_x_result;
short *sobel_y_result;
unsigned short *sobel_rgb565;
volatile unsigned char *sobel_result;
int sobel_width;
int sobel_height;

void init_sobel_arrays(int width , int height) {
	int loop;
	sobel_width = width;
	sobel_height = height;
	if (sobel_x_result != NULL)
		free(sobel_x_result);
	sobel_x_result = (short *)malloc(width*height*sizeof(short));
	if (sobel_y_result != NULL)
		free(sobel_y_result);
	sobel_y_result = (short *)malloc(width*height*sizeof(short));
	if (sobel_result != NULL)
		free(sobel_result);
	sobel_result = (unsigned char *)malloc(width*height*sizeof(unsigned char));
	if (sobel_rgb565 != NULL)
		free(sobel_rgb565);
	sobel_rgb565 = (unsigned short *)malloc(width*height*sizeof(unsigned short));
	for (loop = 0 ; loop < width*height ; loop++) {
		sobel_x_result[loop] = 0;
		sobel_y_result[loop] = 0;
		sobel_result[loop] = 0;
		sobel_rgb565[loop] = 0;
	}
}


void sobel_complete(unsigned char *source){

	   int x,y,arrayindex,dataA,dataB;
	   short sum = 0;
	   short resultx = 0;
	   short resulty = 0;
	   const char * filterx = gx_array;
	   const char * filtery = gy_array;

	   for (y = 1 ; y < (sobel_height-1) ; y++) {
	      for (x = 1 ; x < (sobel_width-1) ; x++) {
	    	  // Sobel X
#ifdef CI

	    	   //  result = 1 * dataA[23:16] + 2 * dataA[15:8] + 1 * dataA[7:0]
	    	   //         - 1 * dataB[23:16] - 2 * dataB[15:8] - 1 * dataB[7:0];
	    	   //const char gx_array[3][3] = {{-1,0,1},
	    	   //                             {-2,0,2},
	    	   //                             {-1,0,1}};

	    	  // Using Sobel CI
/*
	    	   dataA = (source[(y-1)*sobel_width+(x+1)]<<16) | (source[(y)*sobel_width+(x+1)]<<8) | source[(y+1)*sobel_width+(x+1)];
	    	   dataB = (source[(y-1)*sobel_width+(x-1)]<<16) | (source[(y)*sobel_width+(x-1)]<<8) | source[(y+1)*sobel_width+(x-1)];
	    	   resultx = ALT_CI_SOBEL_MASK_CI_0(dataA,dataB);
*/

	    	   // Using Sobel CI
	    	   //const char gy_array[3][3] = { {1, 2, 1},
	    	   //                              {0, 0, 0},
	    	   //                             {-1,-2,-1}};
/*
	    	   dataA = (source[(y-1)*sobel_width+(x-1)]<<16) | (source[(y-1)*sobel_width+(x)]<<8) | source[(y-1)*sobel_width+(x+1)];
	    	   //dataA = (*( (int *) &source[(y-1)*sobel_width+(x-1)]) >>8);
			   dataB = (source[(y+1)*sobel_width+(x-1)]<<16) | (source[(y+1)*sobel_width+(x)]<<8) | source[(y+1)*sobel_width+(x+1)];
	    	   //dataB = (*( (int *) &source[(y+1)*sobel_width+(x-1)]) >>8);
			   resultx = ALT_CI_SOBEL_MASK_CI_0(dataA,dataB);

			   sum = (resultx < 0 ? -resultx:resultx)
			   					+ (resulty < 0 ? -resulty:resulty);
*/
	    	    // Sobel XY with CI
	    	  	// Cram 8 bits of relevant image data into 2 32 bit numbers
	    	    // image = 0 1 2
	    	    //         3 X 4
	    	    //         5 6 7
	    	  	// DataA = bytes 0,1,2,3 in this order
	    	    // DataB = bytes 5,6,7,4 in this order


	    	    dataA = (int) ( (int)(source[(y-1)*sobel_width+(x-1)]<<24) | (int)(source[(y-1)*sobel_width+(x)]<<16) | (int)(source[(y-1)*sobel_width+(x+1)]<<8)  | (int)(source[(y)*sobel_width+(x-1)]<<0));

	    	    dataB = (int) ( (int)(source[(y+1)*sobel_width+(x-1)]<<24) | (int)(source[(y+1)*sobel_width+(x)]<<16) | (int)(source[(y+1)*sobel_width+(x+1)]<<8)  | (int)(source[(y)*sobel_width+(x+1)]<<0));

	    	    //resultx = (short) ((ALT_CI_SOBEL_XY_CI_0(dataA,dataB)&0x0000FFF7)<<2);
	    	    //resultx = (short) ((ALT_CI_SOBEL_XY_CI_0(dataA,dataB)&0xFFFF0000));
	    	    //resultx = ((resultx&0x000000FF)<<8) | (resultx>>8);
/*
	    	    dataA = (int) ((source[(y-1)*sobel_width+(x-1)]<<0) | (source[(y-1)*sobel_width+(x)]<<8)
	    	    	| (source[(y-1)*sobel_width+(x+1)]<<24)  | (source[(y)*sobel_width+(x-1)]<<24));

				dataB = (int) ((source[(y+1)*sobel_width+(x-1)]<<0) | (source[(y+1)*sobel_width+(x)]<<8)
					| (source[(y+1)*sobel_width+(x+1)]<<16)  | (source[(y)*sobel_width+(x+1)]<<24));

				resultx = (short) ((ALT_CI_SOBEL_XY_CI_0(dataA,dataB)&0x0000FFFF));
	    	    //resultx = ((resultx&0x000000FF)<<8) | (resultx>>8);
*/
	    	  	//sum = resultx & 0x0000FFFF;

#else
	    	   resultx = filterx[0] * source[(y-1)*sobel_width+(x-1)]
					  + filterx[2] * source[(y-1)*sobel_width+(x+1)]
					  + filterx[3] * source[(y)*sobel_width+(x-1)]
					  + filterx[5] * source[(y)*sobel_width+(x+1)]
					  + filterx[6] * source[(y+1)*sobel_width+(x-1)]
					  + filterx[8] * source[(y+1)*sobel_width+(x+1)];

	    	   // Sobel y

	    	   resulty = filtery[0] * source[(y-1)*sobel_width+(x-1)]
					  + filtery[1] * source[(y-1)*sobel_width+(x)]
					  + filtery[2] * source[(y-1)*sobel_width+(x+1)]
					  + filtery[6] * source[(y+1)*sobel_width+(x-1)]
					  + filtery[7] * source[(y+1)*sobel_width+(x)]
					  + filtery[8] * source[(y+1)*sobel_width+(x+1)];

				sum = (resultx < 0 ? -resultx:resultx)
					+ (resulty < 0 ? -resulty:resulty);
#endif






				arrayindex = (y*sobel_width)+x;



				// If sum is greater than 128
				//sobel_result[arrayindex] = (sum >> 7) ? 0xFF : 0;
				//sobel_result[arrayindex] = (sum >128) ? 0xFF : 0;
				sobel_result[arrayindex] = (unsigned char) (ALT_CI_SOBEL_XY_CI_0(dataA,dataB) & 0x000000FF);


	      }
	   }
	   return;
}



short sobel_mac( unsigned char *pixels,
                 int x,
                 int y,
                 const char *filter,
                 unsigned int width ) {
   short dy,dx;
   short result = 0;
   for (dy = -1 ; dy < 2 ; dy++) {
      for (dx = -1 ; dx < 2 ; dx++) {
         result += filter[(dy+1)*3+(dx+1)]*
                   pixels[(y+dy)*width+(x+dx)];
      }
   }
   return result;
}


short sobel_mac_unrollx( unsigned char *pixels,
                 int x,
                 int y,
                 const char *filter,
                 unsigned int width ) {
   short dy,dx;
   short result = 0;
   for (dy = -1 ; dy < 2 ; dy++) {
       result += filter[(dy+1)*3+(0)]*pixels[(y+dy)*width+(x-1)];
       result += filter[(dy+1)*3+(1)]*pixels[(y+dy)*width+(x)];
       result += filter[(dy+1)*3+(2)]*pixels[(y+dy)*width+(x+1)];
   }
   return result;
}


short sobel_mac_unroll( unsigned char *pixels,
                 int x,
                 int y,
                 const char *filter,
                 unsigned int width ) {
   short result = 0;

   // dy = -1, dx from -1 to 1

   result += filter[0] * pixels[(y-1)*width+(x-1)];
   result += filter[1] * pixels[(y-1)*width+(x+0)];
   result += filter[2] * pixels[(y-1)*width+(x+1)];

   result += filter[3] * pixels[(y)*width+(x-1)];
   result += filter[4] * pixels[(y)*width+(x+0)];
   result += filter[5] * pixels[(y)*width+(x+1)];

   result += filter[6] * pixels[(y+1)*width+(x-1)];
   result += filter[7] * pixels[(y+1)*width+(x+0)];
   result += filter[8] * pixels[(y+1)*width+(x+1)];

   return result;
}


void sobel_x( unsigned char *source ) {
   int x,y;

   for (y = 1 ; y < (sobel_height-1) ; y++) {
      for (x = 1 ; x < (sobel_width-1) ; x++) {
         sobel_x_result[y*sobel_width+x] = sobel_mac(source,x,y,gx_array,sobel_width);
      }
   }
}

void sobel_x_inline(unsigned char *source){
   int x,y;


   short dy,dx;
   short result = 0;
   char maskValue = 0;


   for (y = 1 ; y < (sobel_height-1) ; y++) {
	  for (x = 1 ; x < (sobel_width-1) ; x++) {
		  // Sobel_mac function
		  result = 0;
		   for (dy = -1 ; dy < 2 ; dy++) {
		      for (dx = -1 ; dx < 2 ; dx++) {
		    	  maskValue = gx_array[(dy+1)*3+(dx+1)];
		         result += source[(y+dy)*sobel_width+(x+dx)] * maskValue;
		      }
		   }

		 sobel_x_result[y*sobel_width+x] = result;
	  }
   }
}

void sobel_x_with_rgb( unsigned char *source ) {
   int x,y;
   short result;

   for (y = 1 ; y < (sobel_height-1) ; y++) {
      for (x = 1 ; x < (sobel_width-1) ; x++) {
    	  result = sobel_mac(source,x,y,gx_array,sobel_width);
          sobel_x_result[y*sobel_width+x] = result;
          if (result < 0) {
        	  sobel_rgb565[y*sobel_width+x] = ((-result)>>2)<<5;
          } else {
        	  sobel_rgb565[y*sobel_width+x] = ((result>>3)&0x1F)<<11;
          }
      }
   }
}

void sobel_y( unsigned char *source ) {
   int x,y;

   for (y = 1 ; y < (sobel_height-1) ; y++) {
      for (x = 1 ; x < (sobel_width-1) ; x++) {
         sobel_y_result[y*sobel_width+x] = sobel_mac(source,x,y,gy_array,sobel_width);
      }
   }
}

void sobel_y_inline(unsigned char *source){
   int x,y;


   short dy,dx;
   short result = 0;
   char maskValue = 0;


   for (y = 1 ; y < (sobel_height-1) ; y++) {
	  for (x = 1 ; x < (sobel_width-1) ; x++) {
		  // Sobel_mac function
		  result = 0;
		   for (dy = -1 ; dy < 2 ; dy++) {
		      for (dx = -1 ; dx < 2 ; dx++) {

		    	  maskValue = gy_array[(dy+1)*3+(dx+1)];
		         result += source[(y+dy)*sobel_width+(x+dx)] * maskValue;
		      }
		   }

		 sobel_y_result[y*sobel_width+x] = result;
	  }
   }
}

void sobel_y_with_rgb( unsigned char *source ) {
   int x,y;
   short result;

   for (y = 1 ; y < (sobel_height-1) ; y++) {
      for (x = 1 ; x < (sobel_width-1) ; x++) {
    	  result = sobel_mac(source,x,y,gy_array,sobel_width);
         sobel_y_result[y*sobel_width+x] = result;
         if (result < 0) {
       	  sobel_rgb565[y*sobel_width+x] = ((-result)>>2)<<5;
         } else {
       	  sobel_rgb565[y*sobel_width+x] = ((result>>3)&0x1F)<<11;
         }
      }
   }
}

void sobel_threshold(short threshold) {
	int x,y,arrayindex;
	short sum,value;
	for (y = 1 ; y < (sobel_height-1) ; y++) {
		for (x = 1 ; x < (sobel_width-1) ; x++) {
			arrayindex = (y*sobel_width)+x;
			value = sobel_x_result[arrayindex];
			sum = (value < 0) ? -value : value;
			value = sobel_y_result[arrayindex];
			sum += (value < 0) ? -value : value;
			sobel_result[arrayindex] = (sum > threshold) ? 0xFF : 0;
		}
	}
}


void sobel_threshold128() {
	int x,y,arrayindex;
	short sum,value;
	for (y = 1 ; y < (sobel_height-1) ; y++) {
		for (x = 1 ; x < (sobel_width-1) ; x++) {
			arrayindex = (y*sobel_width)+x;

			sum = (sobel_x_result[arrayindex] < 0 ? -sobel_x_result[arrayindex]:sobel_x_result[arrayindex])
				+ (sobel_y_result[arrayindex] < 0 ? -sobel_y_result[arrayindex]:sobel_y_result[arrayindex]);

			// If sum is greater than 128
			sobel_result[arrayindex] = (sum >> 7) ? 0xFF : 0;
		}
	}
}

unsigned short *GetSobel_rgb() {
	return sobel_rgb565;
}

unsigned char *GetSobelResult() {
	return sobel_result;
}
