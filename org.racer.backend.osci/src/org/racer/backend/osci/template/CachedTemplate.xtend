package org.racer.backend.osci.template

import java.util.LinkedList
import java.util.List
import net.sf.orcc.backends.CommonPrinter
import net.sf.orcc.backends.ir.BlockFor
import net.sf.orcc.df.Action
import net.sf.orcc.df.Actor
import net.sf.orcc.df.Connection
import net.sf.orcc.df.FSM
import net.sf.orcc.df.Port
import net.sf.orcc.df.State
import net.sf.orcc.df.Transition
import net.sf.orcc.graph.Vertex
import net.sf.orcc.ir.Arg
import net.sf.orcc.ir.ArgByRef
import net.sf.orcc.ir.ArgByVal
import net.sf.orcc.ir.BlockBasic
import net.sf.orcc.ir.BlockIf
import net.sf.orcc.ir.BlockWhile
import net.sf.orcc.ir.Def
import net.sf.orcc.ir.ExprBinary
import net.sf.orcc.ir.ExprBool
import net.sf.orcc.ir.ExprInt
import net.sf.orcc.ir.ExprString
import net.sf.orcc.ir.InstAssign
import net.sf.orcc.ir.InstCall
import net.sf.orcc.ir.InstLoad
import net.sf.orcc.ir.InstReturn
import net.sf.orcc.ir.InstStore
import net.sf.orcc.ir.Instruction
import net.sf.orcc.ir.OpBinary
import net.sf.orcc.ir.Procedure
import net.sf.orcc.ir.Type
import net.sf.orcc.ir.TypeBool
import net.sf.orcc.ir.TypeFloat
import net.sf.orcc.ir.TypeInt
import net.sf.orcc.ir.TypeList
import net.sf.orcc.ir.TypeString
import net.sf.orcc.ir.TypeUint
import net.sf.orcc.ir.TypeVoid
import net.sf.orcc.ir.Use
import net.sf.orcc.ir.Var
import net.sf.orcc.ir.impl.ExprVarImpl
import org.racer.backend.osci.Printer

/*
 * The CommonTemplate is a standard Template without options
 * - Communication : tlm_fifo
 * - Type : non accurate
 */
class CachedTemplate extends CommonPrinter implements Template {

	private List<Var> destroyVarList = newArrayList()

	private final Printer printer;

	//========================================
	//          Constructor
	//========================================
	new(Printer p) {
		printer = p
	}

	//========================================
	//          Get from printer
	//========================================
	def private getOutgoingPortMap() {
		return printer.outgoingPortMap
	}

	def private isScType() {
		return printer.scType
	}

	//========================================
	//            Static Layout
	//========================================
	def static beginSection(String section) '''
		////////////////////////////////////////////////////////////////////////////////
		// «section»
	'''

	def static wrap(CharSequence seq, String separator, Integer limit) {
		var lines = newArrayList()
		var String s = seq.toString
		var int start = 0
		var int end = 0
		do {
			end = s.indexOf(separator, start + limit)
			if(end == -1) end = s.length else end = end + separator.length
			lines.add(s.subSequence(start, end))
			start = end
		} while (end != seq.length)
		'''«FOR line : lines SEPARATOR "\n"»«line»«ENDFOR»'''
	}

	def static getActorName(Vertex v) '''«v.getAdapter(Actor).name»'''

	//========================================
	//             Expressions
	//========================================
	override caseExprBinary(ExprBinary expr) {
		val op = expr.op
		var nextPrec = if (op == OpBinary::SHIFT_LEFT || op == OpBinary::SHIFT_RIGHT) {

				// special case, for shifts always put parentheses because compilers
				// often issue warnings
				Integer::MIN_VALUE;
			} else {
				op.precedence;
			}

		val resultingExpr = '''«expr.e1.printExpr(nextPrec, 0)» «op.stringRepresentation» «expr.e2.printExpr(nextPrec, 1)»'''

		if (op.needsParentheses(precedence, branch)) {
			'''(«resultingExpr»)'''
		} else {
			resultingExpr
		}
	}

	override caseExprBool(ExprBool object) {
		if(object.value) "1" else "0"
	}

	override caseExprInt(ExprInt object) {
		val longVal = object.value.longValue
		if (longVal < Integer::MIN_VALUE || longVal > Integer::MAX_VALUE) {
			'''«longVal»L'''
		} else {
			'''«longVal»'''
		}
	}

	override protected stringRepresentation(OpBinary op) {
		if (op == OpBinary::DIV_INT)
			"/"
		else
			super.stringRepresentation(op)
	}

	//========================================
	//             Types
	//========================================
	def private typing(Procedure p) '''«p.returnType.doSwitch»'''

	def private typing(Port p) '''«p.type.doSwitch»'''

	def private typing(Var v) '''«v.type.doSwitch»'''

	override caseTypeBool(TypeBool type) '''bool'''

	override caseTypeFloat(TypeFloat type) '''float'''

	override caseTypeString(TypeString type) '''std::string'''

	override caseTypeInt(TypeInt type) '''«IF (!isScType)»«type.size.printInt»«ELSE»sc_int<«type.size»>«ENDIF»'''

	override caseTypeUint(TypeUint type) '''«IF (!isScType)»unsigned «type.size.printInt»«ELSE»sc_uint<«type.size»>«ENDIF»'''

	override caseTypeList(TypeList type) '''«type.innermostType.doSwitch»'''

	override caseTypeVoid(TypeVoid type) '''void'''

	def private printInt(int size) {
		if (size <= 8) {
			return "char";
		} else if (size <= 16) {
			return "short";
		} else if (size <= 32) {
			return "int";
		} else if (size <= 64) {
			return "long long";
		} else {
			return "?";
		}
	}

	//========================================
	//             Declarations
	//========================================
	def dispatch indexedName(Def d) '''«IF !d.variable.needAllocation»«d.variable.name»«ELSE»(*«d.variable.name»)«ENDIF»'''

	def dispatch indexedName(Use u) '''«IF !u.variable.needAllocation»«u.variable.name»«ELSE»(*«u.variable.name»)«ENDIF»'''

	def dispatch indexedName(Var v) '''«IF !v.needAllocation»«v.name»«ELSE»(*«v.name»)«ENDIF»'''

	override declare(Var v) '''
		«v.typing» «v.indexedName»«FOR dim : v.type.dimensions»[«dim»]«ENDFOR»;
	'''

	override declare(Procedure proc) '''«proc.typing» «proc.name»(«proc.parameters.join(", ")[variable.declare]»);'''

	override declare(FSM fsm) '''«FOR state : fsm.states SEPARATOR ", "»__state_«state.name»«ENDFOR»'''

	//========================================
	//      Allocations & Initializations
	//========================================
	def private boolean needAllocation(Var v) {
		return (v.type.list) && v.type.sizeInBits > 16384
	}

	def private allocate(Var v) {
		destroyVarList.add(v)
		val TypeList type = v.type as TypeList
		'''
			«v.name» = («type.doSwitch» (*)«FOR dim : type.dimensions»[«dim»]«ENDFOR») malloc(«FOR dim : type.dimensions SEPARATOR "*"»«dim»«ENDFOR»*sizeof(«type.
				doSwitch»));
		'''
	}

	def private declareTemporary(Var v) '''
		«v.typing» __«v.name»«FOR dim : v.type.dimensions»[«dim»]«ENDFOR» = «v.initialValue.doSwitch»;
	'''

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
	//               Blocks
	//========================================
	override caseBlockIf(BlockIf block) '''
		if («block.condition.doSwitch») {
			«FOR thenBlock : block.thenBlocks»«thenBlock.doSwitch»«ENDFOR»
		}«IF block.elseRequired» else {
				«FOR elseBlock : block.elseBlocks»«elseBlock.doSwitch»«ENDFOR»
			}
		«ENDIF»
	'''

	override caseBlockWhile(BlockWhile blockWhile) '''
		while («blockWhile.condition.doSwitch») {
			«FOR block : blockWhile.blocks»«block.doSwitch»«ENDFOR»
		}
	'''

	override caseBlockBasic(BlockBasic block) '''
		«FOR instr : block.instructions»«instr.doSwitch»«ENDFOR»
	'''

	override caseBlockFor(BlockFor block) '''
		for («block.init.join(", ")['''«toExpression»''']» ; «block.condition.doSwitch» ; «block.step.join(", ")[
			'''«toExpression»''']») {
			«FOR contentBlock : block.blocks»«contentBlock.doSwitch»«ENDFOR»
		}
	'''

	//========================================
	//            Instructions
	//========================================
	override caseInstAssign(InstAssign inst) '''
		«inst.target.indexedName» = «inst.value.doSwitch»;
	'''

	override caseInstLoad(InstLoad inst) '''
		«IF ((procedure.eContainer as Action).inputPattern.contains(inst.source.variable) ||
			(procedure.eContainer as Action).peekPattern.contains(inst.source.variable))»
			«inst.target.indexedName» = __port_«inst.source.variable.name»_0.read(«FOR index : inst.indexes»«index.doSwitch»«ENDFOR»);
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

	override caseInstCall(InstCall inst) '''
		«IF inst.print»
			native::println(«inst.arguments.printfArgs.join(", ")»);
		«ELSE»
			«IF inst.target != null»«inst.target.indexedName» = «ENDIF»«IF (inst.procedure.native)»native::«(inst.procedure.
			attribute("package") as List<String>).join("::")»::«ENDIF»«inst.procedure.name»(«inst.arguments.join(", ")[
			printCallArg]»);
		«ENDIF»
	'''

	def private printCallArg(Arg arg) {
		if (arg.byRef) {
			"&" + (arg as ArgByRef).use.indexedName + (arg as ArgByRef).indexes.printArrayIndexes
		} else {
			val v = (arg as ArgByVal).value
			if (v instanceof ExprVarImpl)
				(v as ExprVarImpl).use.indexedName
			else
				v.doSwitch
		}
	}

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
	//            Attributes
	//========================================
	def dispatch attribute(Connection c, String name) {
		return c.getAttribute(name).objectValue
	}

	def dispatch attribute(Procedure p, String name) {
		return p.getAttribute(name).objectValue
	}

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

	override declare(Port p) '''
		«IF !outgoingPortMap.containsKey(p)/* Input Port */»
			ap_fifo_in<«p.typing»> __port_«p.name»_0;
		«ELSE/*Output port */»
			«FOR e : outgoingPortMap.get(p) SEPARATOR "\n"»ap_fifo_out<«p.typing»> __port_«p.name»_«e.attribute("fifoId")»;«ENDFOR»
		«ENDIF»
	'''

	override declareStatus(Port p) '''
		«IF !outgoingPortMap.containsKey(p)»
			int __items_«p.name»_0;
		«ELSE»
			«FOR e : outgoingPortMap.get(p) SEPARATOR "\n"»int __rooms_«p.name»_«e.attribute("fifoId")»;«ENDFOR»
		«ENDIF»
	'''

	override updateStatus(Port p) '''
		«IF !outgoingPortMap.containsKey(p)/* Input status */»
			__items_«p.name»_0 = __port_«p.name»_0.used();
		«ELSE/* Outpout status */»
			«FOR e : outgoingPortMap.get(p) SEPARATOR "\n"»__rooms_«p.name»_«e.attribute("fifoId")» = __port_«p.name»_«e.
			attribute("fifoId")».freed();«ENDFOR»
		«ENDIF»
	'''

	def resetPort(Port p) '''
		«IF !outgoingPortMap.containsKey(p)/* Input status */»
			__port_«p.name»_0.reset();
		«ELSE/* Outpout status */»
			«FOR e : outgoingPortMap.get(p) SEPARATOR "\n"»__port_«p.name»_«e.attribute("fifoId")».reset();«ENDFOR»
		«ENDIF»
	'''

	//========================================
	//        Procedures & Pre-Scheduler
	//========================================		
	override public printProcedure(Procedure p) {
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

	override printInitializer(Actor actor) '''	
		void initialize(){
			«FOR v : actor.stateVars»«v.initValue»«ENDFOR»
			«IF actor.fsm != null»__FSM_state = __state_«actor.fsm.initialState.name»;«ENDIF»
			«FOR action : actor.initializes SEPARATOR "\n"»this->«action.body.name»();«ENDFOR»
		}
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
	'''

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

	override printConstructor(Actor actor) '''
		«FOR v : actor.stateVars.filter(v|v.needAllocation)»«v.allocate»«ENDFOR»
		SC_CTHREAD(schedule, __pin_clock.pos());
		reset_signal_is(__pin_reset_n,false);
	'''

	//========================================
	//            Miscellaneous 
	//========================================
	/**
	  * Print for a type, the corresponding formatted text to
	  * use inside a printf() call.
	  * @param type the type to print
	  * @return printf() type format
	  */
	def private printfFormat(Type type) {
		switch type {
			case type.bool: "i"
			case type.float: "f"
			case type.int && (type as TypeInt).long: "lli"
			case type.int: "i"
			case type.uint && (type as TypeUint).long: "llu"
			case type.uint: "u"
			case type.list: "p"
			case type.string: "s"
			case type.void: "p"
		}
	}

	def private printfArgs(List<Arg> args) {
		val finalArgs = new LinkedList<CharSequence>

		val printfPattern = new StringBuilder
		printfPattern.append('"')

		for (arg : args) {

			if (arg.byRef) {
				printfPattern.append("%" + (arg as ArgByRef).use.variable.type.printfFormat)
				finalArgs.add((arg as ArgByRef).use.variable.name)
			} else if ((arg as ArgByVal).value.exprString) {
				printfPattern.append(((arg as ArgByVal).value as ExprString).value)
			} else {
				printfPattern.append("%" + (arg as ArgByVal).value.type.printfFormat)
				finalArgs.add((arg as ArgByVal).value.doSwitch)
			}

		}
		printfPattern.append('"')
		finalArgs.addFirst(printfPattern.toString)
		return finalArgs
	}

	/**
	 * This helper return a representation of a given instruction without
	 * trailing whitespace and semicolon
	 */
	def private toExpression(Instruction instruction) {
		instruction.doSwitch.toString.replaceAll("([^;]+);(\\s+)?", "$1")
	}
	
	//========================================
	//            Facade interfaces 
	//========================================
	
	override declareGlobals(Actor actor) '''
		«IF !actor.stateVars.empty»
		«"Global Variables".beginSection»
		«FOR global : actor.stateVars»«declare(global)»«ENDFOR»
		«"\n"»
		«ENDIF»
	'''

}
