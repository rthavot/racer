package org.racer.backend.osci

import java.util.Date
import java.util.Map
import net.sf.orcc.df.Actor
import net.sf.orcc.df.Network
import net.sf.orcc.graph.Vertex

/*
 * NetworkPrinter is a facade of the Template 
 */
class NetworkPrinter extends Printer {

	new(Map<String, Object> options) {
		super(options)
	}

	def private getActorName(Vertex v) {
		return v.getAdapter(Actor).name
	}

	override content(Network network) '''
		// «new Date()»
		// Generated from «network.name»
		
		#ifndef __«network.simpleName.toUpperCase»_H__
		#define __«network.simpleName.toUpperCase»_H__
		
		#include <systemc.h>
		#include <tlm.h>
		#include <YACE.h>
		
		«FOR v : network.children SEPARATOR "\n"»#include "«v.actorName».h"«ENDFOR»
		
		SC_MODULE(«network.simpleName») {
		public:
			«beginSection("SystemIO")»
			sc_in_clk     __pin_clock;    // clock input
			sc_in<bool>   __pin_reset_n;  // active low, asynchronous reset input
		
		private:
			«"Define FIFOs".beginSection»
			«FOR edge : network.connections»«template.declare(edge)»«ENDFOR»
		
			«"Define Instances".beginSection»
			«FOR v : network.children SEPARATOR "\n"»«v.actorName» «v.actorName»;«ENDFOR»
		
			public:
			«template.printConstructor(network)»
			
		};
		#endif
	'''

}
