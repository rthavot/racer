package ch.epfl.stimm.yace.backend.osci.hw

/*import ch.epfl.stimm.yace.backend.osci.NetworkPrinter
import net.sf.orcc.df.Networkclass HwNetworkPrinter extends NetworkPrinter {
	
	override compileNetwork(Network network)'''
		// «compileDate()»
		// Generated from «network.name»
		
		#ifndef __«network.simpleName.toUpperCase»_H__
		#define __«network.simpleName.toUpperCase»_H__
		
		#include <yace.h>
		#include <systemc.h>
		#include <tlm.h>
		
		«FOR instance : network.children.actorInstances.filter[!actor.native] SEPARATOR "\n"»#include "«instance.name».h"«ENDFOR»

		#define __DEFAULT_SIZE 4096

		SC_MODULE(«network.simpleName») {
		private:
			«network.defineSystemIO»
			«network.defineConnection»
			«network.defineInstance»
			«network.compileEnvironment»
			public:
			«beginSection("Constructor")»
			SC_CTOR(«network.simpleName») : __clock("clk", 10.0 ,SC_NS),
			«network.initializeNetwork.wrap(", ", 67)»
			{
				«network.compileSystemIO»
				«network.compileConnection»
				SC_THREAD(environment);
			};
			«endSection("Constructor")»
		};
		#endif
	'''
	
	def protected compileEnvironment(Network network)'''	
		«beginSection("Environment")»
		void environment() {
			while(1){
				__reset_n.write(false);
				wait(111, SC_NS);
				__reset_n.write(true);
				wait();
			}
		}
		«endSection("Environment")»
  	'''
	
	def private defineSystemIO(Network network)'''
		«beginSection("SystemIO")»
		sc_clock  __clock;
		sc_signal<bool> __reset_n;
		«endSection("SystemIO")»
	'''
	
	def private compileSystemIO(Network network)'''
		«FOR i : network.children.actorInstances.filter[!actor.native] SEPARATOR "\n"»«i.name».__pin_clock(__clock);«ENDFOR»
		«FOR i : network.children.actorInstances.filter[!actor.native] SEPARATOR "\n"»«i.name».__pin_reset_n(__reset_n);«ENDFOR»
	'''
	
}*/
