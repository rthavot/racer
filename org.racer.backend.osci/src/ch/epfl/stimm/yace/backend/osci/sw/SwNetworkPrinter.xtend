package ch.epfl.stimm.yace.backend.osci.sw

/*import ch.epfl.stimm.yace.backend.osci.NetworkPrinter
import net.sf.orcc.df.Network
class SwNetworkPrinter extends NetworkPrinter {

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
			«network.defineConnection»
			«network.defineInstance»
			«network.compileScheduler»
			public:
			«beginSection("Constructor")»
			SC_CTOR(«network.simpleName») :
			«network.initializeNetwork.wrap(", ",67)»
			{
				«network.compileConnection»
				SC_THREAD(schedule);
			};
			«endSection("Constructor")»
		};
		#endif
	'''
	
	def protected compileScheduler(Network network)'''	
		«beginSection("Scheduler")»
		void schedule() {
			while(1){
				«FOR instance : network.children.actorInstances.filter[!actor.native] SEPARATOR "\n"»«instance.name».schedule();«ENDFOR»
				wait(SC_ZERO_TIME);
			}
		}
		«endSection("Scheduler")»
  	'''
	
}*/
