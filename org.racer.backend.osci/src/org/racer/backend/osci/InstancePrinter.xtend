package org.racer.backend.osci

import java.util.Date
import java.util.Map
import net.sf.orcc.df.Actor
import org.racer.backend.osci.template.Template
import org.racer.backend.osci.template.CommonTemplate
import org.racer.backend.osci.template.FifoTemplate
import org.racer.backend.osci.template.SharedTemplate
import org.racer.backend.osci.template.CachedTemplate

/*
 * InstancePrinter is a facade of the Template 
 */
class InstancePrinter extends Printer {

	private Template template = null;

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

	override content(Actor actor) '''
		// «new Date()»
		// Generated from «entityName»
		#ifndef __«entityName.toUpperCase»_H__
		#define __«entityName.toUpperCase»_H__
		
		#include <systemc.h>	
		#include <tlm.h>
		#include "YACE.h"
		
		using namespace sc_core;
		using namespace tlm;
		
		SC_MODULE(«entityName») {
		public:
			«"SystemIO".beginSection»
			sc_in_clk     __pin_clock;    // clock input
			sc_in<bool>   __pin_reset_n;  // active low, asynchronous reset input
			
			«IF !actor.inputs.empty»
				«"Input Ports".beginSection»
				«FOR port : actor.inputs»«template.declare(port)»«ENDFOR»
				«"\n"»
			«ENDIF»
			«IF !actor.outputs.empty»
				«"Output Ports".beginSection»
				«FOR port : actor.outputs»«template.declare(port)»«ENDFOR»
				«"\n"»
			«ENDIF»
		private:
			«IF !actor.inputs.empty»
				«"Input Port Statuses".beginSection»
				«FOR port : actor.inputs»«template.declareStatus(port)»«ENDFOR»
				«"\n"»
			«ENDIF»
			«IF !actor.outputs.empty»
				«"Output Port Statuses".beginSection»
				«FOR port : actor.outputs»«template.declareStatus(port)»«ENDFOR»
				«"\n"»
			«ENDIF»
			«template.declareGlobals(actor)»
			«IF !actor.procs.filter(p|!p.native).empty»
				«"Functions/procedures".beginSection»
				«FOR procedure : actor.procs.filter(p|!p.native) SEPARATOR "\n"»«template.declare(procedure)»«ENDFOR»
				«"\n"»
			«ENDIF»
			«"booting".beginSection»
			sc_signal<bool> __booting;
			
			«IF actor.fsm != null»
				«"FSM".beginSection»
				int __FSM_state;
				enum __states {
					«CommonTemplate::wrap(template.declare(actor.fsm), ", ", 72)»
				};
				«"\n"»
			«ENDIF»
			«"Initializes".beginSection»
			«FOR action : actor.initializes»«template.printProcedure(action.body)»«"\n"»«ENDFOR»
			«template.printInitializer(actor)»
			
			«"Actions".beginSection»
			«FOR action : actor.actions SEPARATOR "\n"»
				«template.printProcedure(action.scheduler)»
				«'\n'»
				«template.printProcedure(action.body)»
			«ENDFOR»
			
		
		public:
			«"Scheduler".beginSection»
			«template.printScheduler(actor)»
		
			«"Constructor".beginSection»
			SC_CTOR(«entityName»){
				«template.printConstructor(actor)»
			};
		
		};
		
		#endif /* __«entityName.toUpperCase»_H__ */
	'''

}
