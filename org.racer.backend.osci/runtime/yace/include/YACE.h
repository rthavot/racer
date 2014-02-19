#ifndef __YACE_H__
#define __YACE_H__

template<typename T>
void __memset (void *dst, int c, const size_t num){
	T* ptr = (T*)dst;
	for(size_t i=0; i<num; i++)
		ptr[i] = 0;
};

template<typename T>
void __memcpy (void * dst, const void * src, const size_t num ){
	T* ptr = (T*)dst;
	T* ptr_ = (T*)src;
	for(size_t i=0; i<num; i++)
		ptr[i] = ptr_[i];
};

#include "ap_fifo_if.h"

#include "native/yace_native.h"
#include "osci/yace_osci.h"
#include "util/yace_util.h"

#if(__RTL_SIMULATION__)
#define LABEL(id)    
#else
#define LABEL(id) id :   
#endif

#endif