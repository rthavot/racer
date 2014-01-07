#ifndef __YACE_NATIVE_STD_STDIO_SOURCE_H__
#define __YACE_NATIVE_STD_STDIO_SOURCE_H__

#include <systemc.h>
#include <tlm.h>

#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <string>

#include "util/yace_getOpt.h"

extern yace::util::GetOpt opt;

namespace native {
namespace source {

	static FILE *file;
	static int nb;
	static int stop;
	static int nbLoops = 1000;

	static void source_init(){
		stop = 0;
		nb = 0;

		if (opt.input_file.c_str() == NULL)
		{
			std::cerr << "No input file given!" << std::endl;
			exit(1);
		}

		file = fopen(opt.input_file.c_str(), "rb");
		if (file == NULL) {
			if (opt.input_file.c_str() == NULL) 
			{
				opt.input_file = "<null>";
			}
			std::cerr << "could not open file "<<  opt.input_file << std::endl;
			exit(1);
		}
	};

	//static sc_uint<32> source_getNbLoop(){
	static unsigned int source_getNbLoop(){
		return nbLoops;
	};
	
	static unsigned int source_sizeOfFile(){
	//static sc_uint<32> source_sizeOfFile(){
		long curr, end;
		curr = ftell (file);
		fseek (file, 0, 2);
		end = ftell (file);
		fseek (file, curr, 0);
		return end;
	};
	
	static unsigned int source_readNBytes(sc_uint<8> outTable[], sc_uint<32> nbTokenToRead){
		unsigned char * o = new unsigned char[nbTokenToRead.to_int()];
		int n = fread(o, 1, (size_t)nbTokenToRead.to_int(), file);

		if(n < nbTokenToRead.to_int()) {
			fprintf(stderr,"Problem when reading input file.\n");
			exit(-4);
		}

		for(int i=0; i<nbTokenToRead.to_int(); i++){
			outTable[i] = o[i];
		}
		delete o;
		return (unsigned int)n;
	};

	static unsigned int source_readNBytes(unsigned char outTable[], unsigned int nbTokenToRead){
	//static sc_uint<32> source_readNBytes(sc_uint<8> outTable[], sc_uint<32> nbTokenToRead){
		unsigned int n = fread(outTable, 1, (size_t)nbTokenToRead, file);

		if(n < nbTokenToRead) {
			fprintf(stderr,"Problem when reading input file.\n");
			exit(-4);
		}
		return n;
	};
	
	static void source_rewind(){
		if(file != NULL) {
			rewind(file);
		}
	};

	static void source_exit(int exitCode){
		exit(exitCode);
	};

	static bool source_isMaxLoopsReached(void){
		return false;
	}

	static void source_decrementNbLoops(void){
		
	}
	
} }
#endif
