#ifndef __YACE_NATIVE_CH_EPFL_MPEG4_PART2_DISPLAYYUV_H__
#define __YACE_NATIVE_CH_EPFL_MPEG4_PART2_DISPLAYYUV_H__

#include <systemc.h>
#include <tlm.h>

#ifndef NO_DISPLAY
#include "SDL.h"
static SDL_Surface *m_screen;
static SDL_Overlay *m_overlay;
#endif


namespace native {
namespace display {
 
	static void press_a_key(int code)
	{
		char buf[2];
		char *ptrBuff = NULL;

		printf("Press a key to continue\n");
		ptrBuff=fgets(buf, 2, stdin);
		if(ptrBuff == NULL) {
			fprintf(stderr,"error when using fgets\n");
		}
		exit(code);
	}

	static void displayYUV_setSize(int width, int height)
	{
	#ifndef NO_DISPLAY
		//std::cout << "set display to " << width << " x " << height << std::endl;
		m_screen = SDL_SetVideoMode(width, height, 0, 0);
		if (m_screen == NULL) {
			std::cerr <<  "Couldn't set video mode" << width << height << std::endl;
			press_a_key(-1);
		}

		if (m_overlay != NULL) {
			SDL_FreeYUVOverlay(m_overlay);
		}

		m_overlay = SDL_CreateYUVOverlay(width, height, SDL_YV12_OVERLAY, m_screen);
		if (m_overlay == NULL) {
			fprintf(stderr, "Couldn't create overlay: %s\n", SDL_GetError());
			press_a_key(-1);
		}
	#endif
	};

	static void displayYUV_init()
	{
	#ifndef NO_DISPLAY
		// First, initialize SDL's video subsystem.
		if (SDL_Init( SDL_INIT_VIDEO ) < 0) {
			fprintf(stderr, "Video initialization failed: %s\n", SDL_GetError());
			press_a_key(-1);
		}

		SDL_WM_SetCaption("display", NULL);

		atexit(SDL_Quit);
	#endif
	};

	static void compareYUV_init()
	{
	};

	static unsigned char displayYUV_getFlags()
	{
		return 3;
	};
	
	static void displayYUV_displayPicture(sc_uint<8>* pictureBufferY,sc_uint<8>* pictureBufferU,sc_uint<8> * pictureBufferV, sc_int<16> pictureWidth, sc_int<16> pictureHeight)
	{
		unsigned short lastWidth = 0;
		static unsigned short lastHeight = 0;
		static size_t pictureSize = pictureWidth.to_int() * pictureHeight.to_int();
	#ifndef NO_DISPLAY
		SDL_Rect rect = { 0, 0, pictureWidth.to_int(), pictureHeight.to_int() };

		SDL_Event event;

		if((pictureHeight != lastHeight) || (pictureWidth != lastWidth)) {
			displayYUV_setSize(pictureWidth.to_int(), pictureHeight.to_int());
			lastHeight = pictureHeight.to_int();
			lastWidth  = pictureWidth.to_int();
		}
		if (SDL_LockYUVOverlay(m_overlay) < 0) {
			fprintf(stderr, "Can't lock screen: %s\n", SDL_GetError());
			press_a_key(-1);
		}

		unsigned char * y = new unsigned char[pictureSize];
		for(size_t i=0;i<(pictureSize);i++){
			y[i] = (unsigned char)pictureBufferY[i];
		}
		memcpy(m_overlay->pixels[0], y, pictureSize );
		delete y;

		unsigned char * v = new unsigned char[pictureSize / 4];
		for(size_t i=0;i<(pictureSize / 4);i++){
			v[i] = (unsigned char)pictureBufferV[i];
		}
		memcpy(m_overlay->pixels[1], v, pictureSize / 4 );
		delete v;
		
		unsigned char * u = new unsigned char[pictureSize / 4];
		for(size_t i=0;i<(pictureSize/ 4);i++){
			u[i] = (unsigned char)pictureBufferU[i];
		}
		memcpy(m_overlay->pixels[2], u, pictureSize / 4 );
		delete u;

		SDL_UnlockYUVOverlay(m_overlay);
		SDL_DisplayYUVOverlay(m_overlay, &rect);

		/* Grab all the events off the queue. */
		while (SDL_PollEvent(&event)) {
			switch (event.type) {
				case SDL_KEYDOWN:
				case SDL_QUIT:
					exit(0);
					break;
				default:
					break;
			}
		}
	#endif
	}
	
	static void displayYUV_displayPicture(unsigned char* pictureBufferY,unsigned char* pictureBufferU,unsigned char* pictureBufferV, short pictureWidth, short pictureHeight)
	{
		unsigned short lastWidth = 0;
		static unsigned short lastHeight = 0;
	#ifndef NO_DISPLAY
		SDL_Rect rect = { 0, 0, pictureWidth, pictureHeight };

		SDL_Event event;

		if((pictureHeight != lastHeight) || (pictureWidth != lastWidth)) {
			displayYUV_setSize(pictureWidth, pictureHeight);
			lastHeight = pictureHeight;
			lastWidth  = pictureWidth;
		}
		if (SDL_LockYUVOverlay(m_overlay) < 0) {
			fprintf(stderr, "Can't lock screen: %s\n", SDL_GetError());
			press_a_key(-1);
		}

		memcpy(m_overlay->pixels[0], pictureBufferY, pictureWidth * pictureHeight );
		memcpy(m_overlay->pixels[1], pictureBufferV, pictureWidth * pictureHeight / 4 );
		memcpy(m_overlay->pixels[2], pictureBufferU, pictureWidth * pictureHeight / 4 );

		SDL_UnlockYUVOverlay(m_overlay);
		SDL_DisplayYUVOverlay(m_overlay, &rect);

		/* Grab all the events off the queue. */
		while (SDL_PollEvent(&event)) {
			switch (event.type) {
				case SDL_KEYDOWN:
				case SDL_QUIT:
					exit(0);
					break;
				default:
					break;
			}
		}
	#endif
	};

	static void compareYUV_comparePicture(sc_uint<8>* pictureBufferY,sc_uint<8>* pictureBufferU,sc_uint<8> * pictureBufferV, sc_int<16> pictureWidth, sc_int<16> pictureHeight)
	{
	};

	static void compareYUV_comparePicture(unsigned char* pictureBufferY,unsigned char*  pictureBufferU,unsigned char*  pictureBufferV, short  pictureWidth, short pictureHeight)
	{
	};

	static bool source_isMaxLoopsReached(void){
		return false;
	}

	static void source_decrementNbLoops(void){
		
	}

	static void source_exit(int code){
	}

} }
#endif
