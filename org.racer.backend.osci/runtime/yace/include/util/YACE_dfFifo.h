#ifndef __DF_FIFO_H__
#define __DF_FIFO_H__

#include <systemc.h>	
#include <tlm.h>

//#include "ap_mem_if.h"
//#include <math.h>
//#include <map>
using namespace std;

using namespace sc_core;
using namespace tlm;

#define MASK(value,size) ((value)&(size-1))

template <typename T>
class df_fifo {
public:
	T * ram;
	size_t size;
	size_t rd;
	size_t wr;

	df_fifo(size_t size) {
		ram = new T[size];
		this->size = size;
		rd = 0;
		wr = 0;
	};

	~df_fifo(){
		delete ram;
	};

};

template <typename T>
class df_fifo_in {
private:
	df_fifo<T> * f;

public:
	void bind(df_fifo<T> * fifo)
	{ this->f = fifo; };

	void operator () ( df_fifo<T> * fifo )
	{ this->bind( fifo ); }

	T& read()
	{ return f->ram[MASK(f->rd, f->size)]; }

	T& read(int index)
	{ return f->ram[MASK(f->rd + index, f->size)]; }

	T& operator[] (int index)
	{ return f->ram[MASK(f->rd + index, f->size)]; }

	void increase(const size_t &rhs)
	{ f->rd = MASK( f->rd + rhs, 2*f->size ); }

	size_t used()
	{ return f->rd <= f->wr ? f->wr - f->rd : 2*f->size - f->rd + f->wr;}

};

template <typename T>
class df_fifo_out {
private:
	df_fifo<T> * f;

public:
	void bind(df_fifo<T> * fifo)
	{ this->f = fifo; };

	void operator () ( df_fifo<T> * fifo )
	{ this->bind( fifo ); }

	void write(const T &data) {
		f->ram[MASK(f->wr, f->size)] = data;
    };

	void write(int index, const T &data) {
		f->ram[MASK(f->wr + index, f->size)] = data;
    };

	T& operator[] (int index)
	{ return f->ram[MASK(f->wr + index, f->size)]; }

	void increase(const size_t &rhs)
	{ f->wr = MASK( f->wr + rhs, 2*f->size ); }

	size_t freed()
	{ return f->size - (f->rd <= f->wr ? f->wr - f->rd : 2*f->size - f->rd + f->wr);}

};


/*template <typename T, int SIZE=2048>
class df_in {
private:
	sc_port<tlm_fifo_get_if<int>> fin;
	T buffer[SIZE];
	int wr;
	int rd;

public:
	void bind(tlm_fifo<T> & fifo)
	{ this->fin.bind(fifo); };

	void operator () ( tlm_fifo<T> & fifo )
	{ this->bind(fifo); }

	T& read() 
	{ return buffer[MASK(rd, SIZE)]; }

	T& read(int index) 
	{ return buffer[MASK(rd + index, SIZE)]; }

	void increase(const size_t &rhs) 
	{ rd = MASK( rd + rhs, 2*SIZE ); }

	size_t used()
	{ return rd <= wr ? wr - rd : 2*SIZE - rd + wr;}

	size_t freed()
	{ return SIZE - used();}

	void initialize(){
		wr = 0;
		rd = 0;
	}

	void schedule(){
		this->initialize();
		wait();
		while(1){
			if( this->freed() && fin->nb_can_get() ){
				fin->nb_get(buffer[wr]);
				wr = MASK(wr+1,2*SIZE);
			}
			wait();
		}
	}

};

template <typename T, int SIZE=2048>
class df_out {
private:
	sc_port<tlm_fifo_put_if<int>> fout;
	T buffer[SIZE];
	int wr;
	int rd;

public:
	void bind( tlm_fifo<T> &fifo )
	{ this->fout.bind(fifo); }

	void operator () ( tlm_fifo<T> &fifo )
	{ this->bind(fifo ); }

	void write(const T &data) {
		buffer[MASK(wr, SIZE)] = data;
    };

	void write(int index, const T &data) {
		buffer[MASK(wr + index, SIZE)] = data;
    };

	void increase(const size_t &rhs) 
	{ wr = MASK( wr + rhs, 2*SIZE ); }

	size_t used()
	{ return rd <= wr ? wr - rd : 2*SIZE - rd + wr;}

	size_t freed()
	{ return SIZE - used();}

	void initialize(){
		wr = 0;
		rd = 0;
	}

	void schedule(){
		this->initialize();
		wait();
		while(1){
			size_t used = this->used();
			if( (used > 0) && fout->nb_can_put()){
				fout->nb_put(buffer[rd]);
				rd = MASK(rd+1,2*SIZE);
			}
			wait();
		}
	}

};*/



#endif /* __DF_FIFO_H__ */