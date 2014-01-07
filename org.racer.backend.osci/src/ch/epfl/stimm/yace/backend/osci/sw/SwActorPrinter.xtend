package ch.epfl.stimm.yace.backend.osci.sw

import ch.epfl.stimm.yace.backend.osci.ActorPrinter
import net.sf.orcc.ir.Var
import net.sf.orcc.df.Instance
import net.sf.orcc.df.Actor
import net.sf.orcc.df.Transition
import net.sf.orcc.df.Stateclass SwActorPrinter extends ActorPrinter {   
	
	override compileInstance(Instance instance){
    	this.instance = instance
    	'''
		// «compileDate()»
		// Generated from «instance.actor.name»
		#ifndef __«instance.name.toUpperCase»_H__
		#define __«instance.name.toUpperCase»_H__
		
		#include <yace.h>
		#include <systemc.h>	
		#include <tlm.h>
		
		using namespace sc_core;
		using namespace tlm;
		using namespace yace::native;
		
		SC_MODULE(«instance.name») {
		public:
			«instance.actor.compileInputs»
			«instance.actor.compileOutputs»
			«instance.actor.compileParameters»
		private:
			«instance.actor.compileInputPortStatuses»
			«instance.actor.compileOutputPortStatuses»
			«instance.actor.compileStateVars»
			«instance.actor.compileProcedures»
			«instance.actor.compileInitializes»
			«instance.actor.compileActions»
			«instance.actor.compileFsmStates»
		public:
			«instance.actor.compileScheduler»
			«beginSection("Constructor")»
			SC_CTOR(«instance.name»){
				«instance.actor.compileConstructor»
				«IF !instance.actor.initializes.empty»this->initialize();«ENDIF»
			};
			«endSection("Constructor")»
		};
		#endif
    	'''
    }
	
	override needAllocation(Var v){
		 if(v.type.list && v.type.sizeInBits > 2048) { return true } else { return false }
	}
	
	def protected compileScheduler(Actor actor)'''	
		«beginSection("Scheduler")»
		void schedule() {	
			«FOR p : actor.inputs SEPARATOR "\n"»__items_«p.name»[0] = __port_«p.name»[0]->used();«ENDFOR»
			«FOR p : actor.outputs SEPARATOR "\n"»«FOR e : instance.outgoingPortMap.get(p) SEPARATOR "\n"»__rooms_«p.name»[«e.compileAttribute("fifoId")»] = __port_«p.name»[«e.compileAttribute("fifoId")»]->size() - __port_«p.name»[«e.compileAttribute("fifoId")»]->used();«ENDFOR»«ENDFOR»
		
			bool __done = false;
			while (!__done) {
				«IF actor.fsm!=null»
				«FOR action : actor.actionsOutsideFsm BEFORE "if" SEPARATOR " else if"»«action.compileScheduler(null)»«ENDFOR»
				switch(__FSM_state) {
					«FOR state : actor.fsm.states»
					case __state_«state.name»:
						«FOR edge : state.outgoing BEFORE "if" SEPARATOR " else if"»«(edge as Transition).action.compileScheduler(edge.target as State)»«ENDFOR»
						break;
					«ENDFOR»
				}
				«ELSE»
				«FOR action : actor.actionsOutsideFsm BEFORE "if" SEPARATOR " else if"»«action.compileScheduler(null)»«ENDFOR»
				«ENDIF»
				__done = true;
			}
		}
		«endSection("Scheduler")»
	'''

	override compileHasExecuted()
	'''continue;'''

}
