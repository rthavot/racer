#ifndef __AP_FIFO_IF_H__
#define __AP_FIFO_IF_H__

#include "ap_mem_if.h"

#define __1X__  0
#define __2X__  1
#define __4X__  2
#define __8X__  3
#define __16X__ 4
#define __32X__ 5
#define __64X__ 6

#define __NX__ __64X__

#define MASK(value, size) ((value)&(size-1))
#define USED(lhs, rhs, size) (lhs <= rhs ? rhs - lhs : 2*size - lhs + rhs)

#define LSB(value, n) ((value & ((1<<n)-1)))
#define MSB(value, n) (value >> n)

typedef int Address;

template <typename T, int SIZE=512>
class ap_fifo {
public :
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_0;
#if  (__NX__>=__2X__)
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_1;
#endif
#if  (__NX__>=__4X__)
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_2;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_3;
#endif
#if  (__NX__>=__8X__)
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_4;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_5;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_6;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_7;
#endif
#if  (__NX__>=__16X__)
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_8;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_9;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_10;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_11;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_12;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_13;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_14;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_15;
#endif
#if  (__NX__>=__32X__)
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_16;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_17;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_18;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_19;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_20;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_21;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_22;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_23;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_24;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_25;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_26;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_27;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_28;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_29;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_30;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_31;
#endif
#if  (__NX__>=__64X__)
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_32;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_33;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_34;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_35;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_36;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_37;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_38;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_39;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_40;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_41;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_42;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_43;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_44;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_45;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_46;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_47;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_48;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_49;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_50;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_51;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_52;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_53;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_54;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_55;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_56;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_57;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_58;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_59;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_60;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_61;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_62;
	ap_mem_chn<T, Address, (SIZE>>__NX__), RAM_1P> channel_63;
#endif
	sc_signal<Address> rd;
	sc_signal<Address> wr;
};

template <typename T, int SIZE=512>
class ap_fifo_out {
private :
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_0;
#if  (__NX__>=__2X__)
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_1;
#endif
#if  (__NX__>=__4X__)
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_2;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_3;
#endif
#if  (__NX__>=__8X__)
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_4;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_5;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_6;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_7;
#endif
#if  (__NX__>=__16X__)
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_8;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_9;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_10;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_11;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_12;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_13;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_14;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_15;
#endif
#if  (__NX__>=__32X__)
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_16;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_17;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_18;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_19;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_20;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_21;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_22;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_23;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_24;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_25;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_26;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_27;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_28;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_29;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_30;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_31;
#endif
#if  (__NX__>=__64X__)
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_32;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_33;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_34;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_35;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_36;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_37;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_38;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_39;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_40;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_41;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_42;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_43;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_44;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_45;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_46;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_47;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_48;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_49;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_50;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_51;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_52;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_53;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_54;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_55;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_56;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_57;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_58;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_59;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_60;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_61;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_62;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_63;
#endif
	sc_in<Address> rd;
	sc_out<Address> wr;
	sc_signal<Address> awr;

public:
	ap_fifo_out(const char * ram_name,const char * rd_name, const char * wr_name) 
		: rd(rd_name), wr(wr_name), ram_0(ram_name)
#if  (__NX__>=__2X__)
		,ram_1(ram_name)
#endif
#if  (__NX__>=__4X__)
		,ram_2(ram_name), ram_3(ram_name)
#endif
#if  (__NX__>=__8X__)
		,ram_4(ram_name), ram_5(ram_name),ram_6(ram_name), ram_7(ram_name)
#endif
#if  (__NX__>=__16X__)
		,ram_8(ram_name), ram_9(ram_name),ram_10(ram_name), ram_11(ram_name)
		,ram_12(ram_name), ram_13(ram_name),ram_14(ram_name), ram_15(ram_name)
#endif
#if  (__NX__>=__32X__)
		,ram_16(ram_name), ram_17(ram_name),ram_18(ram_name), ram_19(ram_name)
		,ram_20(ram_name), ram_21(ram_name),ram_22(ram_name), ram_23(ram_name)
		,ram_24(ram_name), ram_25(ram_name),ram_26(ram_name), ram_27(ram_name)
		,ram_28(ram_name), ram_29(ram_name),ram_30(ram_name), ram_31(ram_name)
#endif
#if  (__NX__>=__64X__)
		,ram_32(ram_name), ram_33(ram_name),ram_34(ram_name), ram_35(ram_name)
		,ram_36(ram_name), ram_37(ram_name),ram_38(ram_name), ram_39(ram_name)
		,ram_40(ram_name), ram_41(ram_name),ram_42(ram_name), ram_43(ram_name)
		,ram_44(ram_name), ram_45(ram_name),ram_46(ram_name), ram_47(ram_name)
		,ram_48(ram_name), ram_49(ram_name),ram_50(ram_name), ram_51(ram_name)
		,ram_52(ram_name), ram_53(ram_name),ram_54(ram_name), ram_55(ram_name)
		,ram_56(ram_name), ram_57(ram_name),ram_58(ram_name), ram_59(ram_name)
		,ram_60(ram_name), ram_61(ram_name),ram_62(ram_name), ram_63(ram_name)
#endif
	{}

	/*ap_fifo_out()
		: ram("unknown")
	{}*/

	void bind(ap_fifo<T,SIZE> *fifo){ 
		ram_0(fifo->channel_0);
#if (__NX__>=__2X__)
		ram_1(fifo->channel_1);
#endif
#if (__NX__>=__4X__)
		ram_2(fifo->channel_2);
		ram_3(fifo->channel_3);
#endif
#if (__NX__>=__8X__)
		ram_4(fifo->channel_4);
		ram_5(fifo->channel_5);
		ram_6(fifo->channel_6);
		ram_7(fifo->channel_7);
#endif
#if (__NX__>=__16X__)
		ram_8(fifo->channel_8);
		ram_9(fifo->channel_9);
		ram_10(fifo->channel_10);
		ram_11(fifo->channel_11);
		ram_12(fifo->channel_12);
		ram_13(fifo->channel_13);
		ram_14(fifo->channel_14);
		ram_15(fifo->channel_15);
#endif
#if (__NX__>=__32X__)
		ram_16(fifo->channel_16);
		ram_17(fifo->channel_17);
		ram_18(fifo->channel_18);
		ram_19(fifo->channel_19);
		ram_20(fifo->channel_20);
		ram_21(fifo->channel_21);
		ram_22(fifo->channel_22);
		ram_23(fifo->channel_23);
		ram_24(fifo->channel_24);
		ram_25(fifo->channel_25);
		ram_26(fifo->channel_26);
		ram_27(fifo->channel_27);
		ram_28(fifo->channel_28);
		ram_29(fifo->channel_29);
		ram_30(fifo->channel_30);
		ram_31(fifo->channel_31);
#endif
#if (__NX__>=__64X__)
		ram_32(fifo->channel_32);
		ram_33(fifo->channel_33);
		ram_34(fifo->channel_34);
		ram_35(fifo->channel_35);
		ram_36(fifo->channel_36);
		ram_37(fifo->channel_37);
		ram_38(fifo->channel_38);
		ram_39(fifo->channel_39);
		ram_40(fifo->channel_40);
		ram_41(fifo->channel_41);
		ram_42(fifo->channel_42);
		ram_43(fifo->channel_43);
		ram_44(fifo->channel_44);
		ram_45(fifo->channel_45);
		ram_46(fifo->channel_46);
		ram_47(fifo->channel_47);
		ram_48(fifo->channel_48);
		ram_49(fifo->channel_49);
		ram_50(fifo->channel_50);
		ram_51(fifo->channel_51);
		ram_52(fifo->channel_52);
		ram_53(fifo->channel_53);
		ram_54(fifo->channel_54);
		ram_55(fifo->channel_55);
		ram_56(fifo->channel_56);
		ram_57(fifo->channel_57);
		ram_58(fifo->channel_58);
		ram_59(fifo->channel_59);
		ram_60(fifo->channel_60);
		ram_61(fifo->channel_61);
		ram_62(fifo->channel_62);
		ram_63(fifo->channel_63);
#endif
		rd(fifo->rd);
		wr(fifo->wr);
	}

	void operator () ( ap_fifo<T,SIZE> * fifo ){ 
		this->bind( fifo );
	}

	void write(int index, const T &data) {
		Address addr = MASK( awr.read() + index, SIZE);
		switch(LSB(addr,__NX__)){
		case 0: { ram_0[(int)MSB(addr,__NX__)] = data; break; }
#if (__NX__>=__2X__)
		case 1: { ram_1[(int)MSB(addr,__NX__)] = data; break; }
#endif
#if (__NX__>=__4X__)
		case 2: { ram_2[(int)MSB(addr,__NX__)] = data; break; }
		case 3: { ram_3[(int)MSB(addr,__NX__)] = data; break; }
#endif
#if (__NX__>=__8X__)
		case 4: { ram_4[(int)MSB(addr,__NX__)] = data; break; }
		case 5: { ram_5[(int)MSB(addr,__NX__)] = data; break; }
		case 6: { ram_6[(int)MSB(addr,__NX__)] = data; break; }
		case 7: { ram_7[(int)MSB(addr,__NX__)] = data; break; }
#endif
#if (__NX__>=__16X__)
		case 8: { ram_8[(int)MSB(addr,__NX__)] = data; break; }
		case 9: { ram_9[(int)MSB(addr,__NX__)] = data; break; }
		case 10: { ram_10[(int)MSB(addr,__NX__)] = data; break; }
		case 11: { ram_11[(int)MSB(addr,__NX__)] = data; break; }
		case 12: { ram_12[(int)MSB(addr,__NX__)] = data; break; }
		case 13: { ram_13[(int)MSB(addr,__NX__)] = data; break; }
		case 14: { ram_14[(int)MSB(addr,__NX__)] = data; break; }
		case 15: { ram_15[(int)MSB(addr,__NX__)] = data; break; }
#endif
#if (__NX__>=__32X__)
		case 16: { ram_16[(int)MSB(addr,__NX__)] = data; break; }
		case 17: { ram_17[(int)MSB(addr,__NX__)] = data; break; }
		case 18: { ram_18[(int)MSB(addr,__NX__)] = data; break; }
		case 19: { ram_19[(int)MSB(addr,__NX__)] = data; break; }
		case 20: { ram_20[(int)MSB(addr,__NX__)] = data; break; }
		case 21: { ram_21[(int)MSB(addr,__NX__)] = data; break; }
		case 22: { ram_22[(int)MSB(addr,__NX__)] = data; break; }
		case 23: { ram_23[(int)MSB(addr,__NX__)] = data; break; }
		case 24: { ram_24[(int)MSB(addr,__NX__)] = data; break; }
		case 25: { ram_25[(int)MSB(addr,__NX__)] = data; break; }
		case 26: { ram_26[(int)MSB(addr,__NX__)] = data; break; }
		case 27: { ram_27[(int)MSB(addr,__NX__)] = data; break; }
		case 28: { ram_28[(int)MSB(addr,__NX__)] = data; break; }
		case 29: { ram_29[(int)MSB(addr,__NX__)] = data; break; }
		case 30: { ram_30[(int)MSB(addr,__NX__)] = data; break; }
		case 31: { ram_31[(int)MSB(addr,__NX__)] = data; break; }
#endif
#if (__NX__>=__64X__)
		case 32: { ram_32[(int)MSB(addr,__NX__)] = data; break; }
		case 33: { ram_33[(int)MSB(addr,__NX__)] = data; break; }
		case 34: { ram_34[(int)MSB(addr,__NX__)] = data; break; }
		case 35: { ram_35[(int)MSB(addr,__NX__)] = data; break; }
		case 36: { ram_36[(int)MSB(addr,__NX__)] = data; break; }
		case 37: { ram_37[(int)MSB(addr,__NX__)] = data; break; }
		case 38: { ram_38[(int)MSB(addr,__NX__)] = data; break; }
		case 39: { ram_39[(int)MSB(addr,__NX__)] = data; break; }
		case 40: { ram_40[(int)MSB(addr,__NX__)] = data; break; }
		case 41: { ram_41[(int)MSB(addr,__NX__)] = data; break; }
		case 42: { ram_42[(int)MSB(addr,__NX__)] = data; break; }
		case 43: { ram_43[(int)MSB(addr,__NX__)] = data; break; }
		case 44: { ram_44[(int)MSB(addr,__NX__)] = data; break; }
		case 45: { ram_45[(int)MSB(addr,__NX__)] = data; break; }
		case 46: { ram_46[(int)MSB(addr,__NX__)] = data; break; }
		case 47: { ram_47[(int)MSB(addr,__NX__)] = data; break; }
		case 48: { ram_48[(int)MSB(addr,__NX__)] = data; break; }
		case 49: { ram_49[(int)MSB(addr,__NX__)] = data; break; }
		case 50: { ram_50[(int)MSB(addr,__NX__)] = data; break; }
		case 51: { ram_51[(int)MSB(addr,__NX__)] = data; break; }
		case 52: { ram_52[(int)MSB(addr,__NX__)] = data; break; }
		case 53: { ram_53[(int)MSB(addr,__NX__)] = data; break; }
		case 54: { ram_54[(int)MSB(addr,__NX__)] = data; break; }
		case 55: { ram_55[(int)MSB(addr,__NX__)] = data; break; }
		case 56: { ram_56[(int)MSB(addr,__NX__)] = data; break; }
		case 57: { ram_57[(int)MSB(addr,__NX__)] = data; break; }
		case 58: { ram_58[(int)MSB(addr,__NX__)] = data; break; }
		case 59: { ram_59[(int)MSB(addr,__NX__)] = data; break; }
		case 60: { ram_60[(int)MSB(addr,__NX__)] = data; break; }
		case 61: { ram_61[(int)MSB(addr,__NX__)] = data; break; }
		case 62: { ram_62[(int)MSB(addr,__NX__)] = data; break; }
		case 63: { ram_63[(int)MSB(addr,__NX__)] = data; break; }
#endif
		}
    }

	void increase(const size_t &rhs){
		Address twr = MASK( awr.read() + rhs, 2*SIZE );
		awr.write(twr);
		wr.write(twr);
	}

	size_t freed(){
		Address trd = rd.read();
		Address twr = awr.read();
		return SIZE - USED(trd, twr, SIZE);
	}

	void reset(){
		awr.write(0);
		wr.write(0);
		ram_0.reset();
#if (__NX__>=__2X__)
		ram_1.reset();
#endif
#if (__NX__>=__4X__)
		ram_2.reset(); ram_3.reset();
#endif
#if (__NX__>=__8X__)
		ram_4.reset(); ram_5.reset();
		ram_6.reset(); ram_7.reset();
#endif
#if (__NX__>=__16X__)
		ram_8.reset();  ram_9.reset();
		ram_10.reset(); ram_11.reset();
		ram_12.reset(); ram_13.reset();
		ram_14.reset(); ram_15.reset();
#endif
#if (__NX__>=__32X__)
		ram_16.reset(); ram_17.reset();
		ram_18.reset(); ram_19.reset();
		ram_20.reset(); ram_21.reset();
		ram_22.reset(); ram_23.reset();
		ram_24.reset(); ram_25.reset();
		ram_26.reset(); ram_27.reset();
		ram_28.reset(); ram_29.reset();
		ram_30.reset(); ram_31.reset();
#endif
#if (__NX__>=__64X__)
		ram_32.reset(); ram_33.reset();
		ram_34.reset(); ram_35.reset();
		ram_36.reset(); ram_37.reset();
		ram_38.reset(); ram_39.reset();
		ram_40.reset(); ram_41.reset();
		ram_42.reset(); ram_43.reset();
		ram_44.reset(); ram_45.reset();
		ram_46.reset(); ram_47.reset();
		ram_48.reset(); ram_49.reset();
		ram_50.reset(); ram_51.reset();
		ram_52.reset(); ram_53.reset();
		ram_54.reset(); ram_55.reset();
		ram_56.reset(); ram_57.reset();
		ram_58.reset(); ram_59.reset();
		ram_60.reset(); ram_61.reset();
		ram_62.reset(); ram_63.reset();
#endif
	}

};

template <typename T, int SIZE=512>
class ap_fifo_in {
private :
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_0;
#if (__NX__>=__2X__)
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_1;
#endif
#if (__NX__>=__4X__)
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_2;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_3;
#endif
#if (__NX__>=__8X__)
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_4;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_5;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_6;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_7;
#endif
#if (__NX__>=__16X__)
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_8;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_9;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_10;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_11;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_12;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_13;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_14;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_15;
#endif
#if (__NX__>=__32X__)
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_16;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_17;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_18;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_19;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_20;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_21;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_22;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_23;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_24;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_25;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_26;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_27;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_28;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_29;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_30;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_31;
#endif
#if  (__NX__>=__64X__)
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_32;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_33;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_34;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_35;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_36;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_37;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_38;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_39;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_40;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_41;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_42;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_43;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_44;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_45;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_46;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_47;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_48;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_49;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_50;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_51;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_52;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_53;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_54;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_55;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_56;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_57;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_58;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_59;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_60;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_61;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_62;
	ap_mem_port<T, Address, (SIZE>>__NX__), RAM_1P> ram_63;
#endif
	sc_out<Address> rd;
	sc_in<Address> wr;
	sc_signal<Address> ard;

public:
	ap_fifo_in(const char * ram_name,const char * rd_name, const char * wr_name) 
		:  rd(rd_name), wr(wr_name), ram_0(ram_name)
#if  (__NX__>=__2X__)
		,ram_1(ram_name)
#endif
#if  (__NX__>=__4X__)
		,ram_2(ram_name), ram_3(ram_name)
#endif
#if  (__NX__>=__8X__)
		,ram_4(ram_name), ram_5(ram_name), ram_6(ram_name), ram_7(ram_name)
#endif
#if  (__NX__>=__16X__)
		,ram_8(ram_name), ram_9(ram_name), ram_10(ram_name), ram_11(ram_name)
		,ram_12(ram_name), ram_13(ram_name), ram_14(ram_name), ram_15(ram_name)
#endif
#if  (__NX__>=__32X__)
		,ram_16(ram_name), ram_17(ram_name),ram_18(ram_name), ram_19(ram_name)
		,ram_20(ram_name), ram_21(ram_name),ram_22(ram_name), ram_23(ram_name)
		,ram_24(ram_name), ram_25(ram_name),ram_26(ram_name), ram_27(ram_name)
		,ram_28(ram_name), ram_29(ram_name),ram_30(ram_name), ram_31(ram_name)
#endif
#if  (__NX__>=__64X__)
		,ram_32(ram_name), ram_33(ram_name),ram_34(ram_name), ram_35(ram_name)
		,ram_36(ram_name), ram_37(ram_name),ram_38(ram_name), ram_39(ram_name)
		,ram_40(ram_name), ram_41(ram_name),ram_42(ram_name), ram_43(ram_name)
		,ram_44(ram_name), ram_45(ram_name),ram_46(ram_name), ram_47(ram_name)
		,ram_48(ram_name), ram_49(ram_name),ram_50(ram_name), ram_51(ram_name)
		,ram_52(ram_name), ram_53(ram_name),ram_54(ram_name), ram_55(ram_name)
		,ram_56(ram_name), ram_57(ram_name),ram_58(ram_name), ram_59(ram_name)
		,ram_60(ram_name), ram_61(ram_name),ram_62(ram_name), ram_63(ram_name)
#endif
	{}

	/*ap_fifo_in(void)
		: ram("unknown")
	{}*/

	void bind(ap_fifo<T, SIZE> *fifo){
		ram_0(fifo->channel_0);
#if (__NX__>=__2X__)
		ram_1(fifo->channel_1);
#endif
#if (__NX__>=__4X__)
		ram_2(fifo->channel_2);
		ram_3(fifo->channel_3);
#endif
#if (__NX__>=__8X__)
		ram_4(fifo->channel_4);
		ram_5(fifo->channel_5);
		ram_6(fifo->channel_6);
		ram_7(fifo->channel_7);
#endif
#if (__NX__>=__16X__)
		ram_8(fifo->channel_8);
		ram_9(fifo->channel_9);
		ram_10(fifo->channel_10);
		ram_11(fifo->channel_11);
		ram_12(fifo->channel_12);
		ram_13(fifo->channel_13);
		ram_14(fifo->channel_14);
		ram_15(fifo->channel_15);
#endif
#if (__NX__>=__32X__)
		ram_16(fifo->channel_16);
		ram_17(fifo->channel_17);
		ram_18(fifo->channel_18);
		ram_19(fifo->channel_19);
		ram_20(fifo->channel_20);
		ram_21(fifo->channel_21);
		ram_22(fifo->channel_22);
		ram_23(fifo->channel_23);
		ram_24(fifo->channel_24);
		ram_25(fifo->channel_25);
		ram_26(fifo->channel_26);
		ram_27(fifo->channel_27);
		ram_28(fifo->channel_28);
		ram_29(fifo->channel_29);
		ram_30(fifo->channel_30);
		ram_31(fifo->channel_31);
#endif
#if (__NX__>=__64X__)
		ram_32(fifo->channel_32);
		ram_33(fifo->channel_33);
		ram_34(fifo->channel_34);
		ram_35(fifo->channel_35);
		ram_36(fifo->channel_36);
		ram_37(fifo->channel_37);
		ram_38(fifo->channel_38);
		ram_39(fifo->channel_39);
		ram_40(fifo->channel_40);
		ram_41(fifo->channel_41);
		ram_42(fifo->channel_42);
		ram_43(fifo->channel_43);
		ram_44(fifo->channel_44);
		ram_45(fifo->channel_45);
		ram_46(fifo->channel_46);
		ram_47(fifo->channel_47);
		ram_48(fifo->channel_48);
		ram_49(fifo->channel_49);
		ram_50(fifo->channel_50);
		ram_51(fifo->channel_51);
		ram_52(fifo->channel_52);
		ram_53(fifo->channel_53);
		ram_54(fifo->channel_54);
		ram_55(fifo->channel_55);
		ram_56(fifo->channel_56);
		ram_57(fifo->channel_57);
		ram_58(fifo->channel_58);
		ram_59(fifo->channel_59);
		ram_60(fifo->channel_60);
		ram_61(fifo->channel_61);
		ram_62(fifo->channel_62);
		ram_63(fifo->channel_63);
#endif
		rd(fifo->rd);
		wr(fifo->wr);
	}
	
	void operator () ( ap_fifo<T, SIZE> * fifo ){ 
		this->bind( fifo ); 
	}

	T read(int index){
		T data;
		Address addr = (int)MASK(ard.read() + index, SIZE);
		switch(LSB(addr,__NX__)){
		case 0: { data = ram_0[(int)MSB(addr,__NX__)]; break; }
#if (__NX__>=__2X__)
		case 1: { data = ram_1[(int)MSB(addr,__NX__)]; break; }
#endif
#if (__NX__>=__4X__)
		case 2: { data = ram_2[(int)MSB(addr,__NX__)]; break; }
		case 3: { data = ram_3[(int)MSB(addr,__NX__)]; break; }
#endif
#if (__NX__>=__8X__)
		case 4: { data = ram_4[(int)MSB(addr,__NX__)]; break; }
		case 5: { data = ram_5[(int)MSB(addr,__NX__)]; break; }
		case 6: { data = ram_6[(int)MSB(addr,__NX__)]; break; }
		case 7: { data = ram_7[(int)MSB(addr,__NX__)]; break; }
#endif
#if (__NX__>=__16X__)
		case 8: { data = ram_8[(int)MSB(addr,__NX__)]; break; }
		case 9: { data = ram_9[(int)MSB(addr,__NX__)]; break; }
		case 10: { data = ram_10[(int)MSB(addr,__NX__)]; break; }
		case 11: { data = ram_11[(int)MSB(addr,__NX__)]; break; }
		case 12: { data = ram_12[(int)MSB(addr,__NX__)]; break; }
		case 13: { data = ram_13[(int)MSB(addr,__NX__)]; break; }
		case 14: { data = ram_14[(int)MSB(addr,__NX__)]; break; }
		case 15: { data = ram_15[(int)MSB(addr,__NX__)]; break; }
#endif
#if (__NX__>=__32X__)
		case 16: { data = ram_16[(int)MSB(addr,__NX__)]; break; }
		case 17: { data = ram_17[(int)MSB(addr,__NX__)]; break; }
		case 18: { data = ram_18[(int)MSB(addr,__NX__)]; break; }
		case 19: { data = ram_19[(int)MSB(addr,__NX__)]; break; }
		case 20: { data = ram_20[(int)MSB(addr,__NX__)]; break; }
		case 21: { data = ram_21[(int)MSB(addr,__NX__)]; break; }
		case 22: { data = ram_22[(int)MSB(addr,__NX__)]; break; }
		case 23: { data = ram_23[(int)MSB(addr,__NX__)]; break; }
		case 24: { data = ram_24[(int)MSB(addr,__NX__)]; break; }
		case 25: { data = ram_25[(int)MSB(addr,__NX__)]; break; }
		case 26: { data = ram_26[(int)MSB(addr,__NX__)]; break; }
		case 27: { data = ram_27[(int)MSB(addr,__NX__)]; break; }
		case 28: { data = ram_28[(int)MSB(addr,__NX__)]; break; }
		case 29: { data = ram_29[(int)MSB(addr,__NX__)]; break; }
		case 30: { data = ram_30[(int)MSB(addr,__NX__)]; break; }
		case 31: { data = ram_31[(int)MSB(addr,__NX__)]; break; }
#endif
#if (__NX__>=__64X__)
		case 32: { data = ram_32[(int)MSB(addr,__NX__)]; break; }
		case 33: { data = ram_33[(int)MSB(addr,__NX__)]; break; }
		case 34: { data = ram_34[(int)MSB(addr,__NX__)]; break; }
		case 35: { data = ram_35[(int)MSB(addr,__NX__)]; break; }
		case 36: { data = ram_36[(int)MSB(addr,__NX__)]; break; }
		case 37: { data = ram_37[(int)MSB(addr,__NX__)]; break; }
		case 38: { data = ram_38[(int)MSB(addr,__NX__)]; break; }
		case 39: { data = ram_39[(int)MSB(addr,__NX__)]; break; }
		case 40: { data = ram_40[(int)MSB(addr,__NX__)]; break; }
		case 41: { data = ram_41[(int)MSB(addr,__NX__)]; break; }
		case 42: { data = ram_42[(int)MSB(addr,__NX__)]; break; }
		case 43: { data = ram_43[(int)MSB(addr,__NX__)]; break; }
		case 44: { data = ram_44[(int)MSB(addr,__NX__)]; break; }
		case 45: { data = ram_45[(int)MSB(addr,__NX__)]; break; }
		case 46: { data = ram_46[(int)MSB(addr,__NX__)]; break; }
		case 47: { data = ram_47[(int)MSB(addr,__NX__)]; break; }
		case 48: { data = ram_48[(int)MSB(addr,__NX__)]; break; }
		case 49: { data = ram_49[(int)MSB(addr,__NX__)]; break; }
		case 50: { data = ram_50[(int)MSB(addr,__NX__)]; break; }
		case 51: { data = ram_51[(int)MSB(addr,__NX__)]; break; }
		case 52: { data = ram_52[(int)MSB(addr,__NX__)]; break; }
		case 53: { data = ram_53[(int)MSB(addr,__NX__)]; break; }
		case 54: { data = ram_54[(int)MSB(addr,__NX__)]; break; }
		case 55: { data = ram_55[(int)MSB(addr,__NX__)]; break; }
		case 56: { data = ram_56[(int)MSB(addr,__NX__)]; break; }
		case 57: { data = ram_57[(int)MSB(addr,__NX__)]; break; }
		case 58: { data = ram_58[(int)MSB(addr,__NX__)]; break; }
		case 59: { data = ram_59[(int)MSB(addr,__NX__)]; break; }
		case 60: { data = ram_60[(int)MSB(addr,__NX__)]; break; }
		case 61: { data = ram_61[(int)MSB(addr,__NX__)]; break; }
		case 62: { data = ram_62[(int)MSB(addr,__NX__)]; break; }
		case 63: { data = ram_63[(int)MSB(addr,__NX__)]; break; }
#endif
		}
		return data;
	}

	void increase(const size_t &rhs){ 
		Address trd = MASK( ard.read() + rhs, 2*SIZE );
		ard.write(trd);
		rd.write(trd);
	}

	size_t used(){
		Address trd = ard.read();
		Address twr = wr.read();
		return USED(trd, twr, SIZE);
	}

	void reset(){
		ard.write(0);
		rd.write(0);
		ram_0.reset();
#if (__NX__>=__2X__)
		ram_1.reset();
#endif
#if (__NX__>=__4X__)
		ram_2.reset(); ram_3.reset();
#endif
#if (__NX__>=__8X__)
		ram_4.reset(); ram_5.reset();
		ram_6.reset(); ram_7.reset();
#endif
#if (__NX__>=__16X__)
		ram_8.reset();  ram_9.reset();
		ram_10.reset(); ram_11.reset();
		ram_12.reset(); ram_13.reset();
		ram_14.reset(); ram_15.reset();
#endif
#if (__NX__>=__32X__)
		ram_16.reset(); ram_17.reset();
		ram_18.reset(); ram_19.reset();
		ram_20.reset(); ram_21.reset();
		ram_22.reset(); ram_23.reset();
		ram_24.reset(); ram_25.reset();
		ram_26.reset(); ram_27.reset();
		ram_28.reset(); ram_29.reset();
		ram_30.reset(); ram_31.reset();
#endif
#if (__NX__>=__64X__)
		ram_32.reset(); ram_33.reset();
		ram_34.reset(); ram_35.reset();
		ram_36.reset(); ram_37.reset();
		ram_38.reset(); ram_39.reset();
		ram_40.reset(); ram_41.reset();
		ram_42.reset(); ram_43.reset();
		ram_44.reset(); ram_45.reset();
		ram_46.reset(); ram_47.reset();
		ram_48.reset(); ram_49.reset();
		ram_50.reset(); ram_51.reset();
		ram_52.reset(); ram_53.reset();
		ram_54.reset(); ram_55.reset();
		ram_56.reset(); ram_57.reset();
		ram_58.reset(); ram_59.reset();
		ram_60.reset(); ram_61.reset();
		ram_62.reset(); ram_63.reset();
#endif
	}

};

#endif /* __AP_FIFO_IF_H__ */
