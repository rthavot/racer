package ch.epfl.stimm.yace.backend.osci

import java.util.Date
import java.util.Map
import java.util.Map.Entry
import net.sf.orcc.df.Action
import net.sf.orcc.df.State
import net.sf.orcc.df.Transition
import net.sf.orcc.ir.Procedure
import net.sf.orcc.df.Port
import net.sf.orcc.ir.Var
import net.sf.orcc.df.Pattern

class OsciInstancePrinter extends OsciTemplate {

	new(Map<String, Object> options) {
		super(options)
	}

	override protected getHeaderContent() '''
		// «new Date()»
		// Generated from «entityName»
		#ifndef __«entityName.toUpperCase»_H__
		#define __«entityName.toUpperCase»_H__
		
		#include <systemc.h>	
		#include <tlm.h>
		#include "cbuffer.h"
		
		using namespace sc_core;
		using namespace tlm;
		
		SC_MODULE(«entityName») {
		public:
			«beginSection("SystemIO")»
			sc_in_clk     __pin_clock;    // clock input
			sc_in<bool>   __pin_reset_n;  // active low, asynchronous reset input
			
			«IF !actor.inputs.empty»
			«beginSection("Input Ports")»
			«FOR port : actor.inputs SEPARATOR "\n"»//sc_port<tlm_fifo_get_if<«port.type.doSwitch»>> __port_«port.name»[1];«ENDFOR»
			«FOR port : actor.inputs SEPARATOR "\n"»df_fifo_in<«port.type.doSwitch»> __port_«port.name»[1];«ENDFOR»
			«"\n"»
			«ENDIF»
			«IF !actor.outputs.empty»
			«beginSection("Output Ports")»
			«FOR port : actor.outputs SEPARATOR "\n"»//sc_port<tlm_fifo_put_if<«port.type.doSwitch»>> __port_«port.name»[«outgoingPortMap.get(port).size»];«ENDFOR»
			«FOR port : actor.outputs SEPARATOR "\n"»df_fifo_out<«port.type.doSwitch»> __port_«port.name»[«outgoingPortMap.get(port).size»];«ENDFOR»
			«"\n"»
			«ENDIF»
		private:
			«IF !actor.inputs.empty»
			«beginSection("Input Port Statuses")»
			«FOR port : actor.inputs SEPARATOR "\n"»int __items_«port.name»[1];«ENDFOR»
			«"\n"»
			«ENDIF»
			«IF !actor.outputs.empty»
			«beginSection("Output Port Statuses")»
			«FOR port : actor.outputs SEPARATOR "\n"»int __rooms_«port.name»[«outgoingPortMap.get(port).size»];«ENDFOR»
			«"\n"»
			«ENDIF»
			«IF !actor.stateVars.empty»
			«beginSection("Global Variables")»
			«FOR global : actor.stateVars SEPARATOR "\n"»«global.declare»;«ENDFOR»
			«"\n"»
			«ENDIF»
			«IF !actor.procs.filter(p|!p.native).empty»
			«beginSection("Functions/procedures")»
			«FOR procedure : actor.procs.filter(p|!p.native) SEPARATOR "\n"»«procedure.declare»«ENDFOR»
			«"\n"»
			«ENDIF»
			«beginSection("Initializes")»
			«FOR action : actor.initializes SEPARATOR "\n"»«action.body.declare»«ENDFOR»
			void __initialize_actor();
			
			«beginSection("Actions")»
			«FOR action : actor.actions»«action.scheduler.declare»«'\n'»«action.body.declare»«'\n'»«ENDFOR»
			
			«IF actor.fsm != null»
			«beginSection("FSM")»
			int __FSM_state;
			enum __states {
				«actor.fsm.declare.wrap(", ", 72)»
			};
			«"\n"»
			«ENDIF»
		public:
			«beginSection("Scheduler")»
			void __schedule_actor();
		
			«beginSection("Constructor")»
			SC_HAS_PROCESS(«entityName»);
			«entityName»(sc_module_name __sc_name);
		
		};
		
		#endif /* __«entityName.toUpperCase»_H__ */
	'''

	override protected getSourceContent() '''
		// «new Date()»
		// Generated from «entityName»
		
		#include <«entityName».h>
		#include <YACE.h>
		
		«beginSection("Temporary Variables")»
		«FOR v : actor.stateVars.filter(v|v.initialized)»«v.declareTemporary.wrap(", ", 72)»«ENDFOR»
		
		«beginSection("Constructor")»
		«entityName»::«entityName»(sc_module_name __sc_name) : sc_module(__sc_name) {
			«FOR v : actor.stateVars.filter(v|v.needAllocation)»«v.allocate»«ENDFOR»
			// Call schedulers
			SC_METHOD(__schedule_actor);
			sensitive << __pin_clock.pos() << __pin_reset_n;
		};
		
		«IF !actor.procs.filter(p|!p.native).empty»
		 	«beginSection("Functions/procedures")»
		 	«FOR procedure : actor.procs.filter(p|!p.native) SEPARATOR "\n"»«procedure.print»«ENDFOR»
		 	«"\n"»
		«ENDIF»
		«beginSection("Initializes")»
		«FOR action : actor.initializes»«action.body.print»«"\n"»«ENDFOR»
		void «entityName»::__initialize_actor(){
			«FOR v : actor.stateVars»
				«IF !v.type.list && v.initialized»
					«v.name» = «v.initialValue.doSwitch»;
				«ELSEIF !v.type.list»
					«v.name» = 0;
				«ELSEIF v.initialized»
					memcpy(«v.name», __«v.name», «FOR dim : v.type.dimensions SEPARATOR "*"»«dim»«ENDFOR»*sizeof(«v.type.doSwitch»));
				«ELSE»
					memset(«v.name», 0, «FOR dim : v.type.dimensions SEPARATOR "*"»«dim»«ENDFOR»*sizeof(«v.type.doSwitch»));
				«ENDIF»
			«ENDFOR»
			«IF actor.fsm != null»__FSM_state = __state_«actor.fsm.initialState.name»;«ENDIF»
			«FOR action : actor.initializes SEPARATOR "\n"»this->«action.body.name»();«ENDFOR»
		}
		
		«beginSection("Actions")»
		«FOR action : actor.actions SEPARATOR "\n"»
			«action.scheduler.print»
			«'\n'»
			«action.body.print»
		«ENDFOR»
		
		«beginSection("Scheduler")»
		«printScheduler»
		
	'''

	def protected print(Procedure p) {
		procedure = p
		destroyVarList.clear
		'''
			«p.returnType.doSwitch» «entityName»::«p.name»(«p.parameters.join(", ")[variable.declare]»){
				«IF p.eContainer instanceof Action»
					«IF (p.eContainer as Action).body.equals(p)»
						«FOR v : p.locals SEPARATOR "\n"»«v.declare»;«ENDFOR»
						«FOR v : (p.eContainer as Action).inputPattern.variables SEPARATOR "\n"»«v.declare»;«ENDFOR»
						«FOR v : (p.eContainer as Action).outputPattern.variables SEPARATOR "\n"»«v.declare»;«ENDFOR»
						«FOR v : p.locals.filter(v|v.needAllocation)»«v.allocate»«ENDFOR»
						«FOR v : (p.eContainer as Action).inputPattern.variables.filter(v|v.needAllocation)»«v.allocate»«ENDFOR»
						«FOR v : (p.eContainer as Action).outputPattern.variables.filter(v|v.needAllocation)»«v.allocate»«ENDFOR»
						«FOR e : (p.eContainer as Action).inputPattern.portToVarMap»«e.compileRead((p.eContainer as Action).inputPattern)»«ENDFOR»
					«ELSE»
						«FOR v : p.locals SEPARATOR "\n"»«v.declare»;«ENDFOR»
						«FOR v : (p.eContainer as Action).peekPattern.variables»«v.declare»;«ENDFOR»
						«FOR v : (p.eContainer as Action).peekPattern.variables.filter(v|v.needAllocation)»«v.allocate»«ENDFOR»
						«FOR e : (p.eContainer as Action).peekPattern.portToVarMap»«e.compilePeek((p.eContainer as Action).peekPattern)»«ENDFOR»
					«ENDIF»
				«ELSE»
					«FOR v : p.locals SEPARATOR "\n"»«v.declare»;«ENDFOR»
					«FOR v : p.locals.filter(v|v.needAllocation)»«v.allocate»«ENDFOR»
				«ENDIF»
				«FOR block : p.blocks»
					«block.doSwitch»
				«ENDFOR»
			}
		'''
	}

	def protected printScheduler() '''	
		void «entityName»::__schedule_actor() {
			if(!__pin_reset_n.read()){
				this->__initialize_actor();
			}else if(__pin_clock.event()){
				«FOR p : actor.inputs SEPARATOR "\n"»__items_«p.name»[0] = __port_«p.name»[0].used();«ENDFOR»
				«FOR p : actor.inputs SEPARATOR "\n"»//__items_«p.name»[0] = __port_«p.name»[0]->used();«ENDFOR»
				«FOR p : actor.outputs SEPARATOR "\n"»«FOR e : outgoingPortMap.get(p) SEPARATOR "\n"»__rooms_«p.name»[«e.compileAttribute("fifoId")»] = __port_«p.name»[«e.compileAttribute("fifoId")»].freed();«ENDFOR»«ENDFOR»
				«FOR p : actor.outputs SEPARATOR "\n"»«FOR e : outgoingPortMap.get(p) SEPARATOR "\n"»//__rooms_«p.name»[«e.compileAttribute("fifoId")»] = __port_«p.name»[«e.compileAttribute("fifoId")»]->size() - __port_«p.name»[«e.compileAttribute("fifoId")»]->used();«ENDFOR»«ENDFOR»
				«IF actor.fsm != null»
				«FOR action : actor.actionsOutsideFsm BEFORE "if" SEPARATOR " else if"»«action.print(null)»«ENDFOR»
				switch(__FSM_state) {
				«FOR state : actor.fsm.states»
				case __state_«state.name»:
					«FOR edge : state.outgoing BEFORE "if" SEPARATOR " else if"»«(edge as Transition).action.print(edge.target as State)»«ENDFOR»
					break;
				«ENDFOR»
				}
				«ELSE»
					«FOR action : actor.actionsOutsideFsm BEFORE "if" SEPARATOR " else if"»«action.print(null)»«ENDFOR»
				«ENDIF»
			}
			«schedulerHasExecuted»
		}
	'''
	

	//========================================
	//            FIFO Access
	//========================================
	override protected compileRead(Entry<Port, Var> e, Pattern p) '''
		«IF p.getNumTokens(e.key) == 1»
			«e.value.compileIndexedName»[0] = __port_«e.key.name»[0].read();
		«ELSE»
			for(int __i=0;__i<«p.getNumTokens(e.key)»;__i++){
				«e.value.compileIndexedName»[__i] = __port_«e.key.name»[0].read(__i);
			}
		«ENDIF»
		__port_«e.key.name»[0].increase(«p.getNumTokens(e.key)»);
	'''

	override protected compilePeek(Entry<Port, Var> e, Pattern p) '''
		«IF p.getNumTokens(e.key) == 1»
			«e.value.compileIndexedName»[0] = __port_«e.key.name»[0].read();
		«ELSE»
			for(int __i=0;__i<«p.getNumTokens(e.key)»;__i++){
				«e.value.compileIndexedName»[__i] = __port_«e.key.name»[0].read(__i);
			}
		«ENDIF»
	'''

	override protected compileWrite(Entry<Port, Var> e, Pattern p) '''
		«IF p.getNumTokens(e.key) == 1»
			«FOR edge : outgoingPortMap.get(e.key) SEPARATOR "\n"»__port_«e.key.name»[«edge.compileAttribute("fifoId")»].write(0,«e.value.compileIndexedName»[0]);«ENDFOR»
		«ELSE»
			for(int __i=0;__i<«p.getNumTokens(e.key)»;__i++){
				«FOR edge : outgoingPortMap.get(e.key) SEPARATOR "\n"»__port_«e.key.name»[«edge.compileAttribute("fifoId")»].write(__i,«e.value.compileIndexedName»[__i]);«ENDFOR»
			}
		«ENDIF»
		«FOR edge : outgoingPortMap.get(e.key) SEPARATOR "\n"»__port_«e.key.name»[«edge.compileAttribute("fifoId")»].increase(«p.getNumTokens(e.key)»);«ENDFOR»
	'''
	
	
}
