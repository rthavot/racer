package org.racer.backend.osci

import java.util.Date
import java.util.Map
import net.sf.orcc.df.Actor

/*
 * InstancePrinter is a facade of the Template 
 */
class InstancePrinter extends Printer {

	new(Map<String, Object> options) {
		super(options)
	}

	override content(Actor actor) '''
		// «new Date()»
		// Generated from «actor.name»
		#ifndef __«actor.name.toUpperCase»_H__
		#define __«actor.name.toUpperCase»_H__
		
		#include <systemc.h>	
		#include <tlm.h>
		#include "YACE.h"
		
		using namespace sc_core;
		using namespace tlm;
		
		SC_MODULE(«actor.name») {
		public:
			«template.printPorts(actor)»
		private:
			«template.printStatuses(actor)»
			«template.printGlobals(actor)»
			«template.printControls(actor)»
			«template.printActions(actor)»
		public:
			«template.printInitializer(actor)»
			«template.printScheduler(actor)»
			«template.printConstructor(actor)»
		
		};
		
		#endif /* __«actor.name.toUpperCase»_H__ */
	'''
	

}
