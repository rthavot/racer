#ifndef __AP_FIFO_IF_H__
#define __AP_FIFO_IF_H__

#include "ap_mem_if.h"

#define MASK(value, size) ((value)&(size-1))
#define USED(lhs, rhs, size) (lhs <= rhs ? rhs - lhs : 2*size - lhs + rhs)

template <typename T, int SIZE=4096>
class ap_fifo {
public :
	ap_mem_chn<T,int, SIZE, RAM_1P> channel;
	sc_signal<int> rd;
	sc_signal<int> wr;
};

template <typename T, int SIZE=4096>
class ap_fifo_out {
private :
	ap_mem_port<T, int, SIZE, RAM_1P> ram;
	sc_in<int> rd;
	sc_out<int> wr;
	sc_signal<int> awr;

public:
	ap_fifo_out(const char * ram_name,const char * rd_name, const char * wr_name) 
		: ram(ram_name), rd(rd_name), wr(wr_name)
	{}

	ap_fifo_out()
		: ram("ram")
	{}

	void bind(ap_fifo<T,SIZE> *fifo){ 
		ram(fifo->channel);
		rd(fifo->rd);
		wr(fifo->wr);
	}

	void operator () ( ap_fifo<T,SIZE> * fifo ){ 
		this->bind( fifo );
	}

	void write(int index, const T &data) {
		ram[MASK( awr.read() + index, SIZE)] = data;
    }


	void increase(const size_t &rhs){
		awr.write(MASK( awr + rhs, 2*SIZE ));
		wr.write(awr.read());
	}

	size_t freed(){
		return SIZE - USED(rd.read(), awr.read(), SIZE);
	}

	void reset(){
		awr.write(0);
		wr.write(0);
		ram.reset();
	}

};

template <typename T, int SIZE=4096>
class ap_fifo_in {
private :
	ap_mem_port<T, int, SIZE, RAM_1P> ram;
	sc_out<int> rd;
	sc_in<int> wr;
	sc_signal<int> ard;

public:
	ap_fifo_in(const char * ram_name,const char * rd_name, const char * wr_name) 
		: ram(ram_name), rd(rd_name), wr(wr_name)
	{}

	ap_fifo_in(void)
		: ram("ram")
	{}

	void bind(ap_fifo<T, SIZE> *fifo){ 
		this->ram(fifo->channel);
		this->rd(fifo->rd);
		this->wr(fifo->wr);
	}
	
	void operator () ( ap_fifo<T, SIZE> * fifo ){ 
		this->bind( fifo ); 
	}

	ap_mem_port<T, int, SIZE, RAM_1P>& read(int index){
		return ram[MASK(ard.read() + index, SIZE)];
	}

	void increase(const size_t &rhs){ 
		ard.write(MASK( ard.read() + rhs, 2*SIZE ));
		rd.write(ard.read());
	}

	size_t used(){
		return USED(ard.read(), wr.read(), SIZE);
	}

	void reset(){
		ard.write(0);
		rd.write(0);
		ram.reset();
	}

};


#endif /* __AP_FIFO_IF_H__ */
