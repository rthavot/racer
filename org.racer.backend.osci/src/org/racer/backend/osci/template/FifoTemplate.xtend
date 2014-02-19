package org.racer.backend.osci.template

import java.util.Map.Entry
import net.sf.orcc.df.Action
import net.sf.orcc.df.Actor
import net.sf.orcc.df.Connection
import net.sf.orcc.df.Pattern
import net.sf.orcc.df.Port
import net.sf.orcc.df.State
import net.sf.orcc.df.Transition
import net.sf.orcc.ir.InstReturn
import net.sf.orcc.ir.Procedure
import net.sf.orcc.ir.TypeList
import net.sf.orcc.ir.Var
import org.racer.backend.osci.Printer
import net.sf.orcc.df.Network

/*
 * The CommonTemplate is a standard Template without options
 * - Communication : tlm_fifo
 * - Type : non accurate
 */
class FifoTemplate extends CommonTemplate implements Template {

	new(Printer p) {
		super(p)
	}

	//========================================
	//      Allocations & Initializations
	//========================================
	def private allocate(Var v) {
		destroyVarList.add(v)
		val TypeList type = v.type as TypeList
		'''
			«v.name» = («type.doSwitch» (*)«FOR dim : type.dimensions»[«dim»]«ENDFOR») malloc(«FOR dim : type.dimensions SEPARATOR "*"»«dim»«ENDFOR»*sizeof(«type.
				doSwitch»));
		'''
	}

	def private initValue(Var v) '''
		«IF !v.type.list && v.initialized»
			«v.name» = «v.initialValue.doSwitch»;
		«ELSEIF !v.type.list»
			«v.name» = 0;
		«ELSEIF v.initialized»
			«v.declareTemporary.wrap(", ", 72)»
			memcpy(«v.name», __«v.name», «FOR dim : v.type.dimensions SEPARATOR "*"»«dim»«ENDFOR»*sizeof(«v.typing»));
		«ELSE»
			memset(«v.name», 0, «FOR dim : v.type.dimensions SEPARATOR "*"»«dim»«ENDFOR»*sizeof(«v.typing»));
		«ENDIF»
	'''

	//========================================
	//            Instructions
	//========================================
	override caseInstReturn(InstReturn inst) '''
		«IF procedure.eContainer instanceof Action»«IF (procedure.eContainer as Action).body.equals(procedure)»
			«FOR e : (procedure.eContainer as Action).outputPattern.portToVarMap»«e.compileWrite(
			(procedure.eContainer as Action).outputPattern)»«ENDFOR»
		«ENDIF»«ENDIF»
		«FOR v : destroyVarList SEPARATOR "\n"»free(«v.name»);«ENDFOR»
		«IF inst.value != null»return «inst.value.doSwitch»;«ENDIF»
	'''

	//========================================
	//            Fifo communications
	//========================================
	def private compileRead(Entry<Port, Var> e, Pattern p) '''
		«IF p.getNumTokens(e.key) == 1»
			__port_«e.key.name»_0->get(«e.value.indexedName»[0]);
		«ELSE»
			for(int __i=0;__i<«p.getNumTokens(e.key)»;__i++){
				__port_«e.key.name»_0->get(«e.value.indexedName»[__i]);
			}
		«ENDIF»
		__items_«e.key.name»_0 -= «p.getNumTokens(e.key)»;
	'''

	def private compilePeek(Entry<Port, Var> e, Pattern p) '''
		«IF p.getNumTokens(e.key) == 1»
			__port_«e.key.name»_0->peek(«e.value.indexedName»[0]);
		«ELSE»
			for(int __i=0;__i<«p.getNumTokens(e.key)»;__i++){
				__port_«e.key.name»_0->peek(«e.value.indexedName»[__i]);
			}
		«ENDIF»
	'''

	def private compileWrite(Entry<Port, Var> e, Pattern p) '''
		«IF p.getNumTokens(e.key) == 1»
			«FOR c : getOutgoingPortMap.get(e.key) SEPARATOR "\n"»__port_«e.key.name»_«c.attribute("fifoId")»->put(«e.value.
			indexedName»[0]);«ENDFOR»
		«ELSE»
			for(int __i=0;__i<«p.getNumTokens(e.key)»;__i++){
				«FOR c : getOutgoingPortMap.get(e.key) SEPARATOR "\n"»__port_«e.key.name»_«c.attribute("fifoId")»->put(«e.value.
			indexedName»[__i]);«ENDFOR»
			}
		«ENDIF»
		«FOR c : getOutgoingPortMap.get(e.key) SEPARATOR "\n"»__rooms_«e.key.name»_«c.attribute("fifoId")» -= «p.
			getNumTokens(e.key)»;«ENDFOR»
	'''

	//========================================
	//            Ports & Fifos
	//========================================
	override declare(Connection c) '''
		tlm_fifo<«c.sourcePort.typing»> fifo_«c.attribute("id")»;
	'''

	override declareSize(Connection c) '''fifo_«c.attribute("id")»(4096)'''

	override declareLink(Connection c) '''
		«c.source.actorName».__port_«c.sourcePort.name»_«c.attribute("fifoId")»(fifo_«c.attribute("id")»);
		«c.target.actorName».__port_«c.targetPort.name»_0(fifo_«c.attribute("id")»);
	'''

	def declare(Port p) '''
		«IF !outgoingPortMap.containsKey(p)/* Input Port */»
			sc_port<tlm_fifo_get_if<«p.typing»>> __port_«p.name»_0;
		«ELSE/*Output port */»
			«FOR e : outgoingPortMap.get(p) SEPARATOR "\n"»sc_port<tlm_fifo_put_if<«p.typing»>> __port_«p.name»_«e.
			attribute("fifoId")»;«ENDFOR»
		«ENDIF»
	'''

	def declareStatus(Port p) '''
		«IF !outgoingPortMap.containsKey(p)»
			int __items_«p.name»_0;
		«ELSE»
			«FOR e : outgoingPortMap.get(p) SEPARATOR "\n"»int __rooms_«p.name»_«e.attribute("fifoId")»;«ENDFOR»
		«ENDIF»
	'''

	def updateStatus(Port p) '''
		«IF !outgoingPortMap.containsKey(p)/* Input status */»
			__items_«p.name»_0 = __port_«p.name»_0->used();
		«ELSE/* Outpout status */»
			«FOR e : outgoingPortMap.get(p) SEPARATOR "\n"»__rooms_«p.name»_«e.attribute("fifoId")» = __port_«p.name»_«e.
			attribute("fifoId")»->size() - __port_«p.name»_«e.attribute("fifoId")»->used();«ENDFOR»
		«ENDIF»
	'''

	def resetPort(Port p) ''''''

	//========================================
	//        Procedures & Pre-Scheduler
	//========================================		
	def public printProcedure(Procedure p) {
		procedure = p
		destroyVarList.clear
		'''
			«p.typing» «p.name»(«p.parameters.join(", ")[variable.declare]»){
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

	def private callAction(Action a, State s) '''
	(«FOR n : a.inputPattern.numTokensMap»__items_«n.key.name»_0 >= «n.value» && «ENDFOR»isSchedulable_«a.name»()) {
		«IF !a.outputPattern.empty»
		if(«FOR n : a.outputPattern.numTokensMap SEPARATOR " && "»«FOR e : getOutgoingPortMap.get(n.key) SEPARATOR " && "»__rooms_«n.
		key.name»_«e.attribute("fifoId")» >= «n.value»«ENDFOR»«ENDFOR») {
			«a.body.name»();
			«IF s != null»__FSM_state = __state_«s.name»;«ENDIF»
			«schedulerHasExecuted»
		}
		«ELSE»
		«a.body.name»();
		«IF s != null»__FSM_state = __state_«s.name»;«ENDIF»
		«schedulerHasExecuted»
		«ENDIF»
	}'''

	def private schedulerHasExecuted() '''
		wait();
		continue;
	'''

	//========================================
	//            Facade interfaces 
	//========================================
	override printGlobals(Actor actor) '''
		«IF !actor.stateVars.empty»
			«"Global Variables".beginSection»
			«FOR global : actor.stateVars»«declare(global)»«ENDFOR»
			«"\n"»
		«ENDIF»
	'''

	override printPorts(Actor actor) '''
		«"SystemIO".beginSection»
		sc_in_clk     __pin_clock;    // clock input
		sc_in<bool>   __pin_reset_n;  // active low, asynchronous reset input
		
		«IF !actor.inputs.empty»
			«"Input Ports".beginSection»
			«FOR port : actor.inputs»«declare(port)»«ENDFOR»
			«"\n"»
		«ENDIF»
		«IF !actor.outputs.empty»
			«"Output Ports".beginSection»
			«FOR port : actor.outputs»«declare(port)»«ENDFOR»
			«"\n"»
		«ENDIF»
	'''

	override printStatuses(Actor actor) '''
		«IF !actor.inputs.empty»
			«"Input Port Statuses".beginSection»
			«FOR port : actor.inputs»«declareStatus(port)»«ENDFOR»
			«"\n"»
		«ENDIF»
		«IF !actor.outputs.empty»
			«"Output Port Statuses".beginSection»
			«FOR port : actor.outputs»«declareStatus(port)»«ENDFOR»
			«"\n"»
		«ENDIF»
	'''

	override printControls(Actor actor) '''
		«"booting".beginSection»
		sc_signal<bool> __booting;
		«IF actor.fsm != null»
			«"\n"»«"FSM".beginSection»
			int __FSM_state;
			enum __states {
				«declare(actor.fsm).wrap(", ", 72)»
			};
		«ENDIF»
		«"\n"»
	'''

	override printActions(Actor actor) '''
		«"Initializes".beginSection»
		«FOR action : actor.initializes»«printProcedure(action.body)»«"\n"»«ENDFOR»
		«"\n"»
		«"Actions".beginSection»
		«FOR action : actor.actions SEPARATOR "\n"»
			«printProcedure(action.scheduler)»
			«'\n'»
			«printProcedure(action.body)»
		«ENDFOR»
		«"\n"»
	'''

	override printInitializer(Actor actor) '''	
		void initialize(){
			«FOR v : actor.stateVars»«v.initValue»«ENDFOR»
			«IF actor.fsm != null»__FSM_state = __state_«actor.fsm.initialState.name»;«ENDIF»
			«FOR action : actor.initializes SEPARATOR "\n"»this->«action.body.name»();«ENDFOR»
		}
		«"\n"»
	'''

	override printScheduler(Actor actor) '''	
		void schedule() {
			__booting.write(true);
			«FOR p : actor.inputs»«p.resetPort»«ENDFOR»
			«FOR p : actor.outputs»«p.resetPort»«ENDFOR»
			wait();
			while(1){
				«FOR p : actor.inputs»«p.updateStatus»«ENDFOR»
				«FOR p : actor.outputs»«p.updateStatus»«ENDFOR»
				if(__booting.read()) {
					this->initialize();
					__booting.write(false);
					«schedulerHasExecuted»
				}«FOR a : actor.actionsOutsideFsm BEFORE "else if" SEPARATOR " else if"»«a.callAction(null)»«ENDFOR»
				«IF actor.fsm != null»
					switch(__FSM_state) {
						«FOR state : actor.fsm.states»
							case __state_«state.name»:
							«FOR e : state.outgoing BEFORE "if" SEPARATOR " else if"»«(e as Transition).action.callAction(e.target as State)»«ENDFOR»
							break;
						«ENDFOR»
					}
				«ENDIF»
				wait();
			}
		}
		«"\n"»
	'''
	
	override printConstructor(Actor actor) '''
		«"Constructor".beginSection»
		SC_CTOR(«actor.name»){
			«FOR v : actor.stateVars.filter(v|v.needAllocation)»«v.allocate»«ENDFOR»
			SC_CTHREAD(schedule, __pin_clock.pos());
			reset_signal_is(__pin_reset_n,false);
		};
	'''

	//========================================
	//            Network
	//========================================
	def protected initializeInstance(Network network) '''«FOR v : network.children SEPARATOR ", "»«v.actorName»("«v.
		actorName»")«ENDFOR»'''
		
	def protected initializeFifo(Network network) '''«FOR edge : network.connections SEPARATOR ", "»«
		declareSize(edge)»«ENDFOR»'''
	
	override printConstructor(Network network) '''
		«"Constructor".beginSection»
			«network.simpleName»(sc_module_name __sc_name) : sc_module(__sc_name),
			«wrap(network.initializeFifo, ", ", 67)»,
			«wrap(network.initializeInstance, ", ", 67)»
			{
				«FOR v : network.children SEPARATOR "\n"»«v.actorName».__pin_clock(__pin_clock);«ENDFOR»
				«FOR v : network.children SEPARATOR "\n"»«v.actorName».__pin_reset_n(__pin_reset_n);«ENDFOR»
				«FOR edge : network.connections»«declareLink(edge)»«ENDFOR»
			};
	'''

}
