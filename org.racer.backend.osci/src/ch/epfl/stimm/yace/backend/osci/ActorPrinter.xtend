package ch.epfl.stimm.yace.backend.osci
import net.sf.orcc.df.Instance
import net.sf.orcc.ir.Var
import net.sf.orcc.ir.Type
import java.util.List
import java.util.Map$Entry
import net.sf.orcc.ir.Procedure
import net.sf.orcc.ir.TypeList
import net.sf.orcc.ir.InstReturn
import net.sf.orcc.df.Action
import net.sf.orcc.ir.InstCall
import net.sf.orcc.df.Pattern
import net.sf.orcc.df.Port
import net.sf.orcc.ir.Def
import net.sf.orcc.ir.Use
import net.sf.orcc.ir.ExprVar
import net.sf.orcc.df.State
import net.sf.orcc.df.Actor
import net.sf.orcc.df.FSM

class ActorPrinter extends StandardPrinter {
	
	protected Instance instance
	protected Procedure procedure
	protected List<Var> destroyVarList = newArrayList()
    
   	def protected defineVariable(Var v, Type type)
	'''«type.doSwitch» «v.compileIndexedName»«FOR dim:type.dimensions»[«dim»]«ENDFOR»'''
	
    
    def protected compileInputs(Actor a)'''
		«IF !a.inputs.empty»
		«beginSection("Input Ports")»
		«FOR port : a.inputs SEPARATOR "\n"»sc_port<tlm_fifo_get_if<«port.type.doSwitch»>> __port_«port.name»[1];«ENDFOR»
		«endSection("Input Ports")»
		«ENDIF»
    '''
    
    def protected compileOutputs(Actor a)'''
	    «IF !a.outputs.empty»
	    «beginSection("Output Ports")»
	    «FOR port : a.outputs SEPARATOR "\n"»sc_port<tlm_fifo_put_if<«port.type.doSwitch»>> __port_«port.name»[«instance.outgoingPortMap.get(port).size»];«ENDFOR»
	    «endSection("Output Ports")»
		«ENDIF»
    '''
    
    def protected compileParameters(Actor a)'''
	    «IF !a.parameters.empty»
	    «beginSection("Parameters")»
	    «FOR parm : a.parameters SEPARATOR "\n"»«parm.defineVariable(parm.type)»;«ENDFOR»
	    «endSection("Parameters")»
		«ENDIF»
    '''
    
    def protected compileInputPortStatuses(Actor a)'''
   		«IF !a.inputs.empty»
   		«beginSection("Input Port Statuses")»
   		«FOR port :a.inputs  SEPARATOR "\n"»int __items_«port.name»[1];«ENDFOR»
   		«endSection("Input Port Statuses")»
		«ENDIF»
    '''
    
    def protected compileOutputPortStatuses(Actor a)'''
   		«IF !a.outputs.empty»
   		«beginSection("Output Port Statuses")»
   		«FOR port : a.outputs  SEPARATOR "\n"»int __rooms_«port.name»[«instance.outgoingPortMap.get(port).size»];«ENDFOR»
   		«endSection("Output Port Statuses")»
		«ENDIF»
    '''
    
    def protected compileStateVars(Actor a)'''
   		«IF !a.stateVars.empty»
   		«beginSection("Global Variables")»
   		«FOR global : a.stateVars SEPARATOR "\n"»
   		«global.defineVariable(global.type)»;«ENDFOR»
   		«endSection("Global Variables")»
		«ENDIF»
    '''
    
    def protected compileProcedures(Actor a)'''
   		«IF !a.procs.filter(p | !p.native).empty»
   		«beginSection("Functions/procedures")»
   		«FOR procedure : a.procs.filter(p | !p.native) SEPARATOR "\n"»«procedure.compileProcedure»«ENDFOR»
   		«endSection("Functions/procedures")»
		«ENDIF»
    '''
    
    def protected compileInitializes(Actor a)'''
   		«IF !a.initializes.empty»
		«beginSection("Initializes")»
		«FOR action : a.initializes SEPARATOR "\n"»«action.body.compileProcedure»«ENDFOR»
		«'\n'»
		void initialize(){
			«FOR action : a.initializes SEPARATOR "\n"»this->«action.body.name»();«ENDFOR»
		}
		«endSection("Initializes")»
		«ENDIF»
    '''
    
    def protected compileActions(Actor a)'''
		«beginSection("Actions")»
		«FOR action : a.actions»
		«action.scheduler.compileProcedure»
		«'\n'»
		«action.body.compileProcedure»
		«endSection("Actions")»
		«ENDFOR»
	'''
    
    def protected compileFsmStates(Actor a) '''
		«IF a.fsm != null»
		«beginSection("FSM")»
		int __FSM_state;
		enum __states {
			«a.fsm.compileFsmStates.wrap(", ", 72)»
		};
		«endSection("FSM")»
		«ENDIF»
    '''
    
    def private compileFsmStates(FSM fsm)
    '''«FOR state : fsm.states SEPARATOR ", "»__state_«state.name»«ENDFOR»'''
	
	def protected compileRead(Entry<Port, Var> e, Pattern p) '''
		«IF p.getNumTokens(e.key)==1»
		__port_«e.key.name»[0]->get(«e.value.compileIndexedName»[0]);
		«ELSE»
		for(int __i=0;__i<«p.getNumTokens(e.key)»;__i++){
			__port_«e.key.name»[0]->get(«e.value.compileIndexedName»[__i]);
		}
		«ENDIF»
		__items_«e.key.name»[0] -= «p.getNumTokens(e.key)»;
	'''
	
	def protected compilePeek(Entry<Port, Var> e, Pattern p) '''
		«IF p.getNumTokens(e.key)==1»
		__port_«e.key.name»[0]->peek(«e.value.compileIndexedName»[0]);
		«ELSE»
		for(int __i=0;__i<«p.getNumTokens(e.key)»;__i++){
			__port_«e.key.name»[0]->peek(«e.value.compileIndexedName»[__i]);
		}
		«ENDIF»
	'''
	
	def protected compileWrite(Entry<Port, Var> e, Pattern p)'''
		«IF p.getNumTokens(e.key)==1»
		«FOR edge : instance.outgoingPortMap.get(e.key) SEPARATOR "\n"»__port_«e.key.name»[«edge.compileAttribute("fifoId")»]->put(«e.value.compileIndexedName»[0]);«ENDFOR»
		«ELSE»
		for(int __i=0;__i<«p.getNumTokens(e.key)»;__i++){
			«FOR edge : instance.outgoingPortMap.get(e.key) SEPARATOR "\n"»__port_«e.key.name»[«edge.compileAttribute("fifoId")»]->put(«e.value.compileIndexedName»[__i]);«ENDFOR»
		}
		«ENDIF»
		«FOR edge : instance.outgoingPortMap.get(e.key) SEPARATOR "\n"»__rooms_«e.key.name»[«edge.compileAttribute("fifoId")»] -= «p.getNumTokens(e.key)»;«ENDFOR»
	'''
	
	def protected compileProcedure(Procedure p){
		procedure = p
		destroyVarList.clear
		'''
		«p.returnType.doSwitch» «p.name»(«FOR param : p.parameters SEPARATOR ", "»«param.variable.defineVariable(param.variable.type)»«ENDFOR»){
			«IF p.eContainer instanceof Action »
				«IF (p.eContainer as Action).body.equals(p)»
					«FOR v : p.locals SEPARATOR "\n"»«v.defineVariable(v.type)»;«ENDFOR»
					«FOR v : (p.eContainer as Action).inputPattern.variables SEPARATOR "\n"»«v.defineVariable(v.type)»;«ENDFOR»
					«FOR v : (p.eContainer as Action).outputPattern.variables SEPARATOR "\n"»«v.defineVariable(v.type)»;«ENDFOR»
					«FOR v : p.locals.filter(v|v.needAllocation)»«v.allocateVariable(v.type as TypeList)»«ENDFOR»
					«FOR v : (p.eContainer as Action).inputPattern.variables.filter(v|v.needAllocation)»«v.allocateVariable(v.type as TypeList)»«ENDFOR»
					«FOR v : (p.eContainer as Action).outputPattern.variables.filter(v|v.needAllocation)»«v.allocateVariable(v.type as TypeList)»«ENDFOR»
					«FOR e : (p.eContainer as Action).inputPattern.portToVarMap»«e.compileRead((p.eContainer as Action).inputPattern)»«ENDFOR»
				«ELSE»
					«FOR v : p.locals SEPARATOR "\n"»«v.defineVariable(v.type)»;«ENDFOR»
					«FOR v : (p.eContainer as Action).peekPattern.variables»«v.defineVariable(v.type)»;«ENDFOR»
					«FOR v : (p.eContainer as Action).peekPattern.variables.filter(v|v.needAllocation)»«v.allocateVariable(v.type as TypeList)»«ENDFOR»
					«FOR e : (p.eContainer as Action).peekPattern.portToVarMap»«e.compilePeek((p.eContainer as Action).peekPattern)»«ENDFOR»
				«ENDIF»
			«ELSE»
				«FOR v : p.locals SEPARATOR "\n"»«v.defineVariable(v.type)»;«ENDFOR»
				«FOR v : p.locals.filter(v|v.needAllocation)»«v.allocateVariable(v.type as TypeList)»«ENDFOR»
			«ENDIF»
			«p.doSwitch»
		}
		'''
	}
	
	def protected allocateVariable(Var v, TypeList t){
		destroyVarList.add(v)
		'''
		«v.name» = («t.doSwitch» (*)«FOR dim:t.dimensions»[«dim»]«ENDFOR») malloc(«FOR dim : t.dimensions SEPARATOR "*"»«dim»«ENDFOR»*sizeof(«t.doSwitch»));
		'''
	}
	
	def protected compileScheduler(Action a, State s) '''
		(«FOR n : a.inputPattern.numTokensMap»__items_«n.key.name»[0] >= «n.value» && «ENDFOR»isSchedulable_«a.name»()) {
			«IF !a.outputPattern.empty»
			if(«FOR n : a.outputPattern.numTokensMap SEPARATOR " && "»«FOR e : instance.outgoingPortMap.get(n.key) SEPARATOR " && "»__rooms_«n.key.name»[«e.compileAttribute("fifoId")»] >= «n.value»«ENDFOR»«ENDFOR») {
				«a.body.name»();
				«IF s != null»__FSM_state = __state_«s.name»;«ENDIF»
				«compileHasExecuted»
			}
			«ELSE»
			«a.body.name»();
			«IF s != null»__FSM_state = __state_«s.name»;«ENDIF»
			«compileHasExecuted»
			«ENDIF»
		}'''
		
	def protected compileHasExecuted()
	''''''
	
	//«FOR arg : instance.arguments.filter(arg|arg.variable.needAllocation)»«arg.variable.allocateVariable(arg.variable.type as TypeList)»«ENDFOR»
	//
	def protected compileConstructor(Actor a)'''
		«FOR p : instance.arguments.filter(p|p.variable.needAllocation)»«p.variable.allocateVariable(p.variable.type as TypeList)»«ENDFOR»
		«FOR p : instance.arguments»«p.variable.name» = «p.value.doSwitch»;«ENDFOR»
		//----
		«FOR v : a.stateVars.filter(v|v.needAllocation)»«v.allocateVariable(v.type as TypeList)»«ENDFOR»
		«FOR v : a.stateVars.filter(v|v.initialized)»«v.initializeVariable»«ENDFOR»
		«IF a.fsm != null»__FSM_state = __state_«a.fsm.initialState.name»;«ENDIF»
	'''
	
	def protected initializeVariable(Var v)'''
		«IF !v.type.list»
			«v.name» = «v.initialValue.doSwitch»;
		«ELSE»
			«v.compileTempVariable.wrap(", ", 72)»
			memcpy(«v.name», __«v.name», «FOR dim : v.type.dimensions SEPARATOR "*"»«dim»«ENDFOR»*sizeof(«v.type.doSwitch»));
		«ENDIF»
	'''
	
	def private compileTempVariable(Var v)
	'''«v.type.doSwitch» __«v.name»«FOR dim:v.type.dimensions»[«dim»]«ENDFOR» = «v.initialValue.doSwitch»;'''
	
	override caseInstReturn(InstReturn r)'''
		«IF procedure.eContainer instanceof Action »«IF (procedure.eContainer as Action).body.equals(procedure)»
			«FOR e : (procedure.eContainer as Action).outputPattern.portToVarMap»«e.compileWrite((procedure.eContainer as Action).outputPattern)»«ENDFOR»
		«ENDIF»«ENDIF»
		«FOR v : destroyVarList SEPARATOR "\n" »free(«v.name»);«ENDFOR»
		«super.caseInstReturn(r)»
	'''
	
	override caseInstCall(InstCall c) '''
		«IF c.print»
			std::cout << " [" << sc_time_stamp() << "] " << «FOR arg : c.parameters SEPARATOR " << "»«arg.compileArg»«ENDFOR»;
		«ELSEIF c.procedure.native»
			«IF c.target!=null»«c.target.compileIndexedName» = «ENDIF»«FOR n : c.procedure.compileAttribute("package") as List<String>»«n»::«ENDFOR»«c.compileCall»;
		«ELSE»
			«super.caseInstCall(c)»
		«ENDIF»
	'''
	
	override dispatch compileIndexedName(Def d)
	'''«IF !d.variable.needAllocation»«d.variable.name»«ELSE»(*«d.variable.name»)«ENDIF»'''
	
	override dispatch compileIndexedName(Use u)
	'''«IF !u.variable.needAllocation»«u.variable.name»«ELSE»(*«u.variable.name»)«ENDIF»'''
	
	override dispatch compileIndexedName(Var v)
	'''«IF !v.needAllocation»«v.name»«ELSE»(*«v.name»)«ENDIF»'''

	override caseExprVar(ExprVar e)
	'''«IF (e.use.variable.type.list) && (e.eContainer.eContainer instanceof InstCall)»«IF (e.eContainer.eContainer as InstCall).procedure.native»«e.use.compileIndexedName»«ELSE»«e.use.variable.name»«ENDIF»«ELSE»«e.use.compileIndexedName»«ENDIF»'''

	def protected boolean needAllocation(Var v){
		if(v.type.list) { return true } else { return false }
	}

}
