package ch.epfl.stimm.yace.backend.osci

import java.io.File
import java.util.Date
import java.util.Map
import net.sf.orcc.df.Actor
import net.sf.orcc.df.Network
import net.sf.orcc.util.OrccUtil

import static org.racer.backend.osci.OsciPathConstant.*

class OsciNetworkPrinter extends OsciTemplate {

	new(Map<String, Object> options) {
		super(options)
	}

	def print(String targetFolder, Network network) {
		val headerFile = new File(targetFolder, INCLUDE + File::separator + network.simpleName + ".h")
		val sourceFile = new File(targetFolder, SRC + File::separator + network.simpleName + ".cpp")

		val header = headerContent(network)
		OrccUtil::printFile(header, headerFile)
		val source = sourceContent(network)
		if (source.length != 0)
			OrccUtil::printFile(source, sourceFile)
		return 0
	}

	def headerContent(Network network) '''
		// «new Date()»
		// Generated from «network.name»
		
		#ifndef __«network.simpleName.toUpperCase»_H__
		#define __«network.simpleName.toUpperCase»_H__
		
		#include <systemc.h>
		#include <tlm.h>
		#include <YACE.h>
		
		«FOR v : network.children SEPARATOR "\n"»#include "«v.getAdapter(Actor).name».h"«ENDFOR»
		
		#define __DEFAULT_SIZE_4096 12
		
		SC_MODULE(«network.simpleName») {
		public:
			«beginSection("SystemIO")»
			sc_in_clk     __pin_clock;    // clock input
			sc_in<bool>   __pin_reset_n;  // active low, asynchronous reset input
		
		private:
			«beginSection("Define FIFOs")»
			«FOR edge : network.connections SEPARATOR "\n"»df_fifo<«edge.sourcePort.type.doSwitch»> fifo_«edge.compileAttribute("id")»;«ENDFOR»
		
			«beginSection("Define Instances")»
			«FOR v : network.children SEPARATOR "\n"»«v.getAdapter(Actor).name» «v.getAdapter(Actor).name»;«ENDFOR»
		
			public:
			«beginSection("Constructor")»
			«network.simpleName»(sc_module_name __sc_name) : sc_module(__sc_name),
			«network.initializeFifo.wrap(", ", 67)»,
			«network.initializeInstance.wrap(", ", 67)»
			{
				«FOR v : network.children SEPARATOR "\n"»«v.getAdapter(Actor).name».__pin_clock(__pin_clock);«ENDFOR»
				«FOR v : network.children SEPARATOR "\n"»«v.getAdapter(Actor).name».__pin_reset_n(__pin_reset_n);«ENDFOR»
				«FOR edge : network.connections»
					«edge.source.getAdapter(Actor).name».__port_«edge.sourcePort.name»[«edge.compileAttribute("fifoId")»](&fifo_«edge.compileAttribute("id")»);
					«edge.target.getAdapter(Actor).name».__port_«edge.targetPort.name»[0](&fifo_«edge.compileAttribute("id")»);
				«ENDFOR»
			};
		};
		#endif
	'''

	def sourceContent(Network network) ''''''

	def protected initializeInstance(Network network) '''«FOR i : network.children SEPARATOR ", "»«i.getAdapter(Actor).name»("«i.getAdapter(Actor).name»")«ENDFOR»'''

	def protected initializeFifo(Network network) '''«FOR i : network.connections SEPARATOR ", "»fifo_«i.compileAttribute("id")»(4096)«ENDFOR»'''

}
