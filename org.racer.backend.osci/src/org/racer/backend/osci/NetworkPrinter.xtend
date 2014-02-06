package org.racer.backend.osci

import java.util.Date
import java.util.Map
import net.sf.orcc.df.Network
import net.sf.orcc.graph.Vertex
import org.racer.backend.osci.template.CommonTemplate
import org.racer.backend.osci.template.Template
import org.racer.backend.osci.template.FifoTemplate
import org.racer.backend.osci.template.SharedTemplate
import org.racer.backend.osci.template.CachedTemplate

/*
 * NetworkPrinter is a facade of the Template 
 */
class NetworkPrinter extends Printer {

	private Template template = null

	new(Map<String, Object> options) {
		super(options)
		if(iacShared)
			template = new SharedTemplate(this)
		if(iacCached)
			template = new CachedTemplate(this)
		else
			template = new FifoTemplate(this)
	}

	def private beginSection(String string){
		return CommonTemplate::beginSection(string)
	}
	
	def private getActorName(Vertex vertex){
		return CommonTemplate::getActorName(vertex)
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
			«CommonTemplate::beginSection("SystemIO")»
			sc_in_clk     __pin_clock;    // clock input
			sc_in<bool>   __pin_reset_n;  // active low, asynchronous reset input
		
		private:
			«"Define FIFOs".beginSection»
			«FOR edge : network.connections»«template.declare(edge)»«ENDFOR»
		
			«"Define Instances".beginSection»
			«FOR v : network.children SEPARATOR "\n"»«v.actorName» «v.actorName»;«ENDFOR»
		
			public:
			«"Constructor".beginSection»
			«network.simpleName»(sc_module_name __sc_name) : sc_module(__sc_name),
			«IF !iacCached»«CommonTemplate::wrap(network.initializeFifo, ", ", 67)»,«ENDIF»
			«CommonTemplate::wrap(network.initializeInstance, ", ", 67)»
			{
				«FOR v : network.children SEPARATOR "\n"»«v.actorName».__pin_clock(__pin_clock);«ENDFOR»
				«FOR v : network.children SEPARATOR "\n"»«v.actorName».__pin_reset_n(__pin_reset_n);«ENDFOR»
				«FOR edge : network.connections»«template.declareLink(edge)»«ENDFOR»
			};
		};
		#endif
	'''

	def protected initializeInstance(Network network) '''«FOR v : network.children SEPARATOR ", "»«v.actorName»("«v.actorName»")«ENDFOR»'''

	def protected initializeFifo(Network network) '''«FOR edge : network.connections SEPARATOR ", "»«template.declareSize(edge)»«ENDFOR»'''

}
