package org.racer.backend.osci

import java.util.Date
import java.util.Map
import net.sf.orcc.df.Actor
import net.sf.orcc.df.State
import net.sf.orcc.df.Transition
import org.racer.backend.osci.Template

/*
 * InstancePrinter is a facade of the Template 
 */
class InstancePrinter extends Printer {

	private Template template = null;

	new(Map<String, Object> options) {
		super(options)
		template = new CommonTemplate(this)
	}
	
	def private beginSection(String string){
		return CommonTemplate::beginSection(string)
	}

	//«FOR port : actor.inputs SEPARATOR "\n"»//df_fifo_in<«template.typing(port.type)»> __port_«port.name»[1];«ENDFOR»
	//«FOR port : actor.outputs SEPARATOR "\n"»//df_fifo_out<«template.typing(port.type)»> __port_«port.name»[«outgoingPortMap.get(port).size»];«ENDFOR»
	override content(Actor actor) '''
		// «new Date()»
		// Generated from «entityName»
		#ifndef __«entityName.toUpperCase»_H__
		#define __«entityName.toUpperCase»_H__
		
		#include <systemc.h>	
		#include <tlm.h>
		#include <YACE.h>
		
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
			«IF !actor.stateVars.empty»
				«"Global Variables".beginSection»
				«FOR global : actor.stateVars SEPARATOR "\n"»«template.declare(global)»;«ENDFOR»
				«"\n"»
			«ENDIF»
			«IF !actor.procs.filter(p|!p.native).empty»
				«"Functions/procedures".beginSection»
				«FOR procedure : actor.procs.filter(p|!p.native) SEPARATOR "\n"»«template.declare(procedure)»«ENDFOR»
				«"\n"»
			«ENDIF»
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

	


//========================================
//            FIFO Access
//========================================
/*def protected compileRead(Entry<Port, Var> e, Pattern p) '''
		«IF p.getNumTokens(e.key) == 1»
			«template.compileIndexedName(e.value)»[0] = __port_«e.key.name»[0].read();
		«ELSE»
			for(int __i=0;__i<«p.getNumTokens(e.key)»;__i++){
				«template.compileIndexedName(e.value)»[__i] = __port_«e.key.name»[0].read(__i);
			}
		«ENDIF»
		__port_«e.key.name»[0].increase(«p.getNumTokens(e.key)»);
	'''

	def protected compilePeek(Entry<Port, Var> e, Pattern p) '''
		«IF p.getNumTokens(e.key) == 1»
			«template.compileIndexedName(e.value)»[0] = __port_«e.key.name»[0].read();
		«ELSE»
			for(int __i=0;__i<«p.getNumTokens(e.key)»;__i++){
				«template.compileIndexedName(e.value)»[__i] = __port_«e.key.name»[0].read(__i);
			}
		«ENDIF»
	'''

	def protected compileWrite(Entry<Port, Var> e, Pattern p) '''
		«IF p.getNumTokens(e.key) == 1»
			«FOR edge : template.outgoingPortMap.get(e.key) SEPARATOR "\n"»__port_«e.key.name»[«template.compileAttribute(edge,"fifoId")»].write(0,«template.compileIndexedName(e.value)»[0]);«ENDFOR»
		«ELSE»
			for(int __i=0;__i<«p.getNumTokens(e.key)»;__i++){
				«FOR edge : template.outgoingPortMap.get(e.key) SEPARATOR "\n"»__port_«e.key.name»[«template.compileAttribute(edge,"fifoId")»].write(__i,«template.compileIndexedName(e.value)»[__i]);«ENDFOR»
			}
		«ENDIF»
		«FOR edge : template.outgoingPortMap.get(e.key) SEPARATOR "\n"»__port_«e.key.name»[«template.compileAttribute(edge,"fifoId")»].increase(«p.getNumTokens(e.key)»);«ENDFOR»
	'''*/
}
