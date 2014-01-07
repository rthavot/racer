#ifndef __UTILS_orcc_Timer_H__
#define __UTILS_orcc_Timer_H__

#include <time.h>
#ifdef _WIN32
#include <windows.h>
#else
#include <sys/time.h>
#endif
class Timer 
{
public:
	Timer::Timer() 
	{
		reset();
	}

	Timer::~Timer() {
	}

	void reset() 
	{
	#if _WIN32
		QueryPerformanceFrequency(&mFrequency);
		QueryPerformanceCounter(&mStartTime);
		mStartTick = GetTickCount();
		mLastTime = 0;
		mZeroClock = clock();
	#else
		mZeroClock = clock();
		gettimeofday(&start, NULL);
	#endif
	};

	unsigned long getMilliseconds()
	{
	#ifdef _WIN32
		LARGE_INTEGER curTime;
		QueryPerformanceCounter(&curTime);
		LONGLONG newTime = curTime.QuadPart - mStartTime.QuadPart;
		unsigned long newTicks = (unsigned long) (1000 * newTime / mFrequency.QuadPart);
		unsigned long check = GetTickCount() - mStartTick;
		signed long msecOff = (signed long)(newTicks - check);
		if (msecOff < -100 || msecOff > 100) {
			LONGLONG adjust = (std::min)(msecOff * mFrequency.QuadPart / 1000, newTime - mLastTime);
			mStartTime.QuadPart += adjust;
			newTime -= adjust;

			newTicks = (unsigned long) (1000 * newTime / mFrequency.QuadPart);
		}
		mLastTime = newTime;
		return newTicks;
	#else
		struct timeval now;
		gettimeofday(&now, NULL);
		return (now.tv_sec-start.tv_sec)*1000+(now.tv_usec-start.tv_usec)/1000;
	#endif
	};

	unsigned long getMicroseconds()
	{
	#ifdef _WIN32
		LARGE_INTEGER curTime;
		QueryPerformanceCounter(&curTime);
		LONGLONG newTime = curTime.QuadPart - mStartTime.QuadPart;
		unsigned long newTicks = (unsigned long) (1000 * newTime / mFrequency.QuadPart);

		unsigned long check = GetTickCount() - mStartTick;
		signed long msecOff = (signed long)(newTicks - check);
		if (msecOff < -100 || msecOff > 100) {
			LONGLONG adjust = (std::min)(msecOff * mFrequency.QuadPart / 1000, newTime - mLastTime);
			mStartTime.QuadPart += adjust;
			newTime -= adjust;
		}
		mLastTime = newTime;
		return (unsigned long) (1000000 * newTime / mFrequency.QuadPart);
	#else
		struct timeval now;
		gettimeofday(&now, NULL);
		return (now.tv_sec-start.tv_sec)*1000000+(now.tv_usec-start.tv_usec);
	#endif
	};

	unsigned long getMillisecondsCPU()
	{
		clock_t newClock = clock();
		return (unsigned long)( (double)( newClock - mZeroClock ) / ( (double)CLOCKS_PER_SEC / 1000.0 ) );
	};

	unsigned long getMicrosecondsCPU()
	{
		clock_t newClock = clock();
		return (unsigned long)( (double)( newClock - mZeroClock ) / ( (double)CLOCKS_PER_SEC / 1000000.0 ) );
	};

private:
#ifdef _WIN32
	unsigned long mStartTick;
	LONGLONG mLastTime;
	LARGE_INTEGER mStartTime;
	LARGE_INTEGER mFrequency;
	unsigned long mTimerMask;

#else
	struct timeval start;
#endif
	clock_t mZeroClock;
};
#endif

