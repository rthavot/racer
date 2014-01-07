#include <iostream> 
 
template <typename T, size_t N> 
class CBuffer 
{ 
public :
	// Variables
	T arr[N];
	size_t wr;
	size_t rd;
	size_t size;
	//
	CBuffer(){
		size = N;
	}
	// Functions
	size_t used(){
		return wr >= rd ? wr - rd : N - rd + wr + 1;
	};
	size_t freed(){
		return wr >= rd ? N - wr - rd : (N << 1) - rd + wr + 1;
	};
}; 