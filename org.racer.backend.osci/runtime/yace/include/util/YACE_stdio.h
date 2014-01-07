#ifndef __UTILS_orcc_Stdio_H__
#define __UTILS_orcc_Stdio_H__

#include <stdio.h>

namespace native {

	static void println(const char * format, ...){
		va_list arg;
		va_start(arg, format);
		vprintf(format,arg);
		va_end(arg);
	};

}

#endif
