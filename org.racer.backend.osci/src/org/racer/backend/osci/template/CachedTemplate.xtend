package org.racer.backend.osci.template

import java.util.List
import net.sf.orcc.df.Action
import net.sf.orcc.df.Actor
import net.sf.orcc.df.Connection
import net.sf.orcc.df.Port
import net.sf.orcc.df.State
import net.sf.orcc.df.Transition
import net.sf.orcc.ir.InstLoad
import net.sf.orcc.ir.InstReturn
import net.sf.orcc.ir.InstStore
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
class CachedTemplate extends CommonTemplate implements Template {
	

	new(Printer p) {
		super(p)
	}
	
	//========================================
	//             Declarations
	//========================================
	
	def private declareConstant(Var v) '''
		«IF v.initialized»
		«IF !v.type.list»
			static const «v.typing» «v.indexedName» = «v.initialValue.doSwitch»;
		«ELSE»
			«v.typing» «v.indexedName»(«FOR i : makeIndexes(v.type.dimensions.size) SEPARATOR ", "»int «i»«ENDFOR»){
				«v.declareTemporary.wrap(",",67)»
				return __«v.indexedName»«FOR i : makeIndexes(v.type.dimensions.size)»[«i»]«ENDFOR»;
			}
		«ENDIF»
		«ENDIF»
	'''
	
	def private makeIndexes(int n) {
		var List<String> indexes = newArrayList
		var i = 0
  		while (i < n) {
  			indexes.add("idx_"+i)
  			i = i + 1;	
  		}
		return indexes
	}
	
	def private initalizeConstructor(Actor actor){
		var List<String> ports = newArrayList
		for(p : actor.inputs)
			ports.add(p.name+"_0");
		for(p : actor.outputs)
		for(c : outgoingPortMap.get(p))
			ports.add(p.name+"_"+c.attribute("fifoId"));
		'''«FOR p : ports SEPARATOR ", "»__port_«p»("«p»","«p»_rd","«p»_wr")«ENDFOR»'''
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
			__memcpy<«v.typing»>(«v.name», __«v.name», «FOR dim : v.type.dimensions SEPARATOR "*"»«dim»«ENDFOR»);
		«ELSE»
			__memset<«v.typing»>(«v.name», 0, «FOR dim : v.type.dimensions SEPARATOR "*"»«dim»«ENDFOR»);
		«ENDIF»
	'''

	//========================================
	//            Instructions
	//========================================

	override caseInstLoad(InstLoad inst) '''
		«IF ((procedure.eContainer as Action).inputPattern.contains(inst.source.variable) ||
			(procedure.eContainer as Action).peekPattern.contains(inst.source.variable))»
			«inst.target.indexedName» = __port_«inst.source.variable.name»_0.read(«FOR index : inst.indexes»«index.doSwitch»«ENDFOR»);
		«ELSEIF !inst.source.variable.assignable && inst.source.variable.type.list »
			«inst.target.indexedName» = «inst.source.indexedName»(«FOR index : inst.indexes SEPARATOR ", "»«index.doSwitch»«ENDFOR»);
		«ELSE»
			«inst.target.indexedName» = «inst.source.indexedName»«FOR index : inst.indexes»[«index.doSwitch»]«ENDFOR»;
		«ENDIF»
	'''

	override caseInstStore(InstStore inst) '''
		«inst.target.indexedName»«FOR index : inst.indexes»[«index.doSwitch»]«ENDFOR» = «inst.value.doSwitch»;
		«IF (procedure.eContainer as Action).outputPattern.contains(inst.target.variable)»
			«FOR c : getOutgoingPortMap.get((procedure.eContainer as Action).outputPattern.getPort(inst.target.variable))»
				__port_«inst.target.variable.name»_«c.attribute("fifoId")».write(«FOR index : inst.indexes»«index.doSwitch»«ENDFOR»,«inst.
			target.indexedName»«FOR index : inst.indexes»[«index.doSwitch»]«ENDFOR»);
			«ENDFOR»
		«ENDIF»
	'''

	override caseInstReturn(InstReturn inst) '''
		«IF procedure.eContainer instanceof Action»«IF (procedure.eContainer as Action).body.equals(procedure)»
			«FOR e : (procedure.eContainer as Action).inputPattern.numTokensMap»
				__port_«e.key.name»_0.increase(«e.value»);
			«ENDFOR»
			«FOR e : (procedure.eContainer as Action).outputPattern.numTokensMap»«FOR c : outgoingPortMap.get(e.key)»
				__port_«e.key.name»_«c.attribute("fifoId")».increase(«e.value»);
			«ENDFOR»«ENDFOR»
		«ENDIF»«ENDIF»
		«FOR v : destroyVarList SEPARATOR "\n"»free(«v.name»);«ENDFOR»
		«IF inst.value != null»return «inst.value.doSwitch»;«ENDIF»
	'''

	//========================================
	//            Ports & Fifos
	//========================================
	override declare(Connection c) '''
		ap_fifo<«c.sourcePort.typing»> fifo_«c.attribute("id")»;
	'''

	override declareSize(Connection c) '''fifo_«c.attribute("id")»(4096)'''

	override declareLink(Connection c) '''
		«c.source.actorName».__port_«c.sourcePort.name»_«c.attribute("fifoId")»(&fifo_«c.attribute("id")»);
		«c.target.actorName».__port_«c.targetPort.name»_0(&fifo_«c.attribute("id")»);
	'''

	def private declare(Port p) '''
		«IF !outgoingPortMap.containsKey(p)/* Input Port */»
			ap_fifo_in<«p.typing»> __port_«p.name»_0;
		«ELSE/*Output port */»
			«FOR e : outgoingPortMap.get(p) SEPARATOR "\n"»ap_fifo_out<«p.typing»> __port_«p.name»_«e.attribute("fifoId")»;«ENDFOR»
		«ENDIF»
	'''

	def private declareStatus(Port p) '''
		«IF !outgoingPortMap.containsKey(p)»
			int __items_«p.name»_0;
		«ELSE»
			«FOR e : outgoingPortMap.get(p) SEPARATOR "\n"»int __rooms_«p.name»_«e.attribute("fifoId")»;«ENDFOR»
		«ENDIF»
	'''

	def private updateStatus(Port p) '''
		«IF !outgoingPortMap.containsKey(p)/* Input status */»
			__items_«p.name»_0 = __port_«p.name»_0.used();
		«ELSE/* Outpout status */»
			«FOR e : outgoingPortMap.get(p) SEPARATOR "\n"»__rooms_«p.name»_«e.attribute("fifoId")» = __port_«p.name»_«e.
			attribute("fifoId")».freed();«ENDFOR»
		«ENDIF»
	'''

	def private resetPort(Port p) '''
		«IF !outgoingPortMap.containsKey(p)/* Input status */»
			__port_«p.name»_0.reset();
		«ELSE/* Outpout status */»
			«FOR e : outgoingPortMap.get(p) SEPARATOR "\n"»__port_«p.name»_«e.attribute("fifoId")».reset();«ENDFOR»
		«ENDIF»
	'''

	//========================================
	//        Procedures & Pre-Scheduler
	//========================================		
	def private printProcedure(Procedure p) {
		procedure = p
		destroyVarList.clear
		'''
			«p.typing» «p.name»(«p.parameters.join(", ")[variable.declare]»){
				«IF p.eContainer instanceof Action»
					«IF (p.eContainer as Action).body.equals(p)»
						«FOR v : p.locals»«v.declare»«ENDFOR»
						«FOR v : (p.eContainer as Action).outputPattern.variables»«v.declare»«ENDFOR»
						«FOR v : p.locals.filter(v|v.needAllocation)»«v.allocate»«ENDFOR»
						«FOR v : (p.eContainer as Action).outputPattern.variables.filter(v|v.needAllocation)»«v.allocate»«ENDFOR»
					«ELSE»
						«FOR v : p.locals»«v.declare»«ENDFOR»
					«ENDIF»
				«ELSE»
					«FOR v : p.locals»«v.declare»«ENDFOR»
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
	//            Instance
	//========================================
	override printGlobals(Actor actor) '''
		«IF !actor.stateVars.empty»
			«"Constants".beginSection»
			«FOR global : actor.stateVars.filter[!assignable && !type.list]»«declareConstant(global)»«ENDFOR»
			«FOR global : actor.stateVars.filter[!assignable && type.list]»«declareConstant(global)»«ENDFOR»
			«"\n"»
			«"Variables".beginSection»
			«FOR global : actor.stateVars.filter[assignable]»«declare(global)»«ENDFOR»
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
	
	override printStatuses(Actor actor)'''
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
		«"Initializer".beginSection»
		void initialize(){
			«FOR v : actor.stateVars.filter[assignable]»«v.initValue»«ENDFOR»
			«IF actor.fsm != null»__FSM_state = __state_«actor.fsm.initialState.name»;«ENDIF»
			«FOR action : actor.initializes SEPARATOR "\n"»this->«action.body.name»();«ENDFOR»
		}
		«"\n"»
	'''

	override printScheduler(Actor actor) '''	
		«"Scheduler".beginSection»
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
		SC_CTOR(«actor.name») :
		«actor.initalizeConstructor.wrap("), ",67)»
		{
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
	
	
	override printConstructor(Network network) '''
		«"Constructor".beginSection»
			«network.simpleName»(sc_module_name __sc_name) : sc_module(__sc_name),
			«wrap(network.initializeInstance, ", ", 67)»
			{
				«FOR v : network.children SEPARATOR "\n"»«v.actorName».__pin_clock(__pin_clock);«ENDFOR»
				«FOR v : network.children SEPARATOR "\n"»«v.actorName».__pin_reset_n(__pin_reset_n);«ENDFOR»
				«FOR edge : network.connections»«declareLink(edge)»«ENDFOR»
			};
	'''
	
	


}
