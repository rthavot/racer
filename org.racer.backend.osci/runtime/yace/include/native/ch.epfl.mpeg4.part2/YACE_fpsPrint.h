#ifndef __YACE_NATIVE_CH_EPFL_MPEG4_PART2_FPSPRINT_H__
#define __YACE_NATIVE_CH_EPFL_MPEG4_PART2_FPSPRINT_H__

#include <systemc.h>
#include <tlm.h>

#define NO_DISPLAY

#ifndef NO_DISPLAY
#include "SDL.h"
static SDL_Surface *m_screen;
static SDL_Overlay *m_overlay;
#else
#include "util/yace_timer.h"
static Timer timer;
#endif

namespace native {
namespace display {

	static unsigned int startTime;
	static unsigned int relativeStartTime;
	static int lastNumPic;
	static int numPicturesDecoded;

	static void print_fps_avg(void) {
	#ifndef NO_DISPLAY
		unsigned int endTime = SDL_GetTicks();
	#else
		unsigned int endTime = timer.getMilliseconds();
	#endif
		printf("%i images in %f seconds: %f FPS\n", numPicturesDecoded,
			(float) (endTime - startTime)/ 1000.0f,
			1000.0f * (float) numPicturesDecoded / (float) (endTime -startTime));
	}

	static void fpsPrintInit(){
	#ifndef NO_DISPLAY
		startTime = SDL_GetTicks();
	#else
		timer.reset();
		startTime = timer.getMilliseconds();
	#endif
		relativeStartTime = startTime;
		numPicturesDecoded = 0;
		lastNumPic = 0;
		atexit(print_fps_avg);
	};
	
	static void fpsPrintNewPicDecoded(){
		unsigned int endTime;
		numPicturesDecoded++;
	#ifndef NO_DISPLAY
		endTime = SDL_GetTicks();
	#else
		endTime = timer.getMilliseconds();
	#endif
		if (endTime - relativeStartTime > 5000) {
			printf("%f images/sec\n",
				1000.0f * (float) (numPicturesDecoded - lastNumPic)
						/ (float) (endTime - relativeStartTime));

			relativeStartTime = endTime;
			lastNumPic = numPicturesDecoded;
		}
	};
	
} }
#endif
