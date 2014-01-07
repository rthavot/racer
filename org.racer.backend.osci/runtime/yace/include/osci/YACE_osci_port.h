#ifndef __UTILS_orcc_Port_H__
#define __UTILS_orcc_Port_H__

#include <systemc.h>    /// main SystemC header
#include <tlm.h>

using namespace sc_core;
using namespace tlm;


namespace yace 
{
namespace osci 
{

	template <typename T>
	class outputPort
	{
	private:

	public:
		sc_port<tlm_fifo_put_if<T>> * port;
		int room;

		void connect(tlm_fifo<T> * port){
			(*this->port)(*port);
		};

		void initialize() {
			port = new sc_port<tlm_fifo_put_if<T>>;
		};

		void update(){
			room = (*port)->size()-(*port)->used();
		};
		
		bool hasRoom(int n){
			return ((*port)->size() < 0)? true : room >= n;
		};
		

	};

	
	template <typename T>
	class inputPort
	{
	private:
		int max;
		
	public:
		sc_port<tlm_fifo_get_if<T>> * port;
		int item;

		void connect(tlm_fifo<T> * port){
			(*this->port)(*port);
		};

		void initialize() {
			port = new sc_port<tlm_fifo_get_if<T>>;
		};

		void update(){
			item = (*port)->used();
		};
		
		bool hasItem(int n){
			return item >= n;
		};

		bool peekMax(int *v){
			bool updates = false; 
			if(item > max){
				max = item;
				updates = true;
			}
			*v = max;
			return updates;
		};

	};
	
	
	
}
}
#endif