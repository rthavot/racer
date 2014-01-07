package ch.epfl.stimm.yace.backend.osci

import java.io.File
import java.util.List
import java.util.Map
import java.util.Map.Entry
import net.sf.orcc.OrccRuntimeException
import net.sf.orcc.backends.c.CTemplate
import net.sf.orcc.backends.ir.BlockFor
import net.sf.orcc.df.Action
import net.sf.orcc.df.Actor
import net.sf.orcc.df.Connection
import net.sf.orcc.df.FSM
import net.sf.orcc.df.Instance
import net.sf.orcc.df.Pattern
import net.sf.orcc.df.Port
import net.sf.orcc.df.State
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
import net.sf.orcc.ir.InstAssign
import net.sf.orcc.ir.InstCall
import net.sf.orcc.ir.InstLoad
import net.sf.orcc.ir.InstReturn
import net.sf.orcc.ir.InstStore
import net.sf.orcc.ir.OpBinary
import net.sf.orcc.ir.Procedure
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
import net.sf.orcc.util.Attributable
import net.sf.orcc.util.OrccLogger
import net.sf.orcc.util.OrccUtil

import static ch.epfl.stimm.yace.backend.osci.OsciPathConstant.*

abstract class OsciTemplate extends CTemplate {

	protected var Instance instance
	protected var Actor actor
	protected var Attributable attributable
	protected var int fifoSize
	protected var Map<Port, Connection> incomingPortMap
	protected var Map<Port, List<Connection>> outgoingPortMap

	protected var String entityName
	protected List<Var> destroyVarList = newArrayList()

	new(Map<String, Object> options) {
	}

	/////////////////////////////////
	// File
	/////////////////////////////////
	/**
	 * Print file content from a given instance
	 *
	 * @param targetFolder folder to print the instance file
	 * @param instance the given instance
	 * @return 1 if file was cached, 0 if file was printed
	 */
	def print(String targetFolder, Instance instance) {
		setInstance(instance)
		print(targetFolder)
	}

	def protected setInstance(Instance instance) {
		if (!instance.isActor) {
			throw new OrccRuntimeException("Instance " + entityName + " is not an Actor's instance")
		}

		this.instance = instance
		this.entityName = instance.name
		this.actor = instance.actor
		this.attributable = instance
		this.incomingPortMap = instance.incomingPortMap
		this.outgoingPortMap = instance.outgoingPortMap
	}

	def print(String targetFolder, Actor actor) {
		setActor(actor)
		print(targetFolder)
	}

	def protected setActor(Actor actor) {
		this.entityName = actor.name
		this.actor = actor
		this.attributable = actor
		this.incomingPortMap = actor.incomingPortMap
		this.outgoingPortMap = actor.outgoingPortMap
	}

	def protected print(String targetFolder) {
		checkConnectivy

		val headerFile = new File(targetFolder, INCLUDE + File::separator + entityName + ".h")
		val sourceFile = new File(targetFolder, SRC + File::separator + entityName + ".cpp")

		val header = headerContent
		if (needToWriteFile(header, headerFile)) {
			OrccUtil::printFile(header, headerFile)
		}

		val content = sourceContent
		if (actor.native) {
			OrccLogger::noticeln(entityName + " is native and not generated.")
		} else if (needToWriteFile(content, sourceFile)) {
			OrccUtil::printFile(content, sourceFile)
			return 0
		} else {
			return 1
		}
	}

	def protected getSourceContent() ''''''

	def protected getHeaderContent() ''''''

	def private checkConnectivy() {
		for (port : actor.inputs.filter[!inputConneted]) {
			OrccLogger::noticeln("[" + entityName + "] Input port " + port.name + " not connected.")
		}
		for (port : actor.outputs.filter[!outputConnected]) {
			OrccLogger::noticeln("[" + entityName + "] Output port " + port.name + " not connected.")
		}
	}

	def private isOutputConnected(Port port) {

		// If the port has a list of output connections not defined or empty, returns false
		!outgoingPortMap.get(port).nullOrEmpty
	}

	def private isInputConneted(Port port) {

		// If the port has an input connection, returns true
		incomingPortMap.get(port) != null
	}

	/////////////////////////////////
	// Layout
	/////////////////////////////////
	def protected beginSection(String section) '''
		////////////////////////////////////////////////////////////////////////////////
		// «section»
	'''

	def protected endSection(String section) '''
		«'\n'»
	'''

	def protected wrap(CharSequence seq, String separator, Integer limit) {
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

	/////////////////////////////////
	// Expressions
	/////////////////////////////////
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

	/////////////////////////////////
	// Types
	/////////////////////////////////
	override caseTypeBool(TypeBool type) '''bool'''

	override caseTypeFloat(TypeFloat type) '''float'''

	override caseTypeString(TypeString type) '''std::string'''

	override caseTypeInt(TypeInt type) '''«type.size.printInt»'''
	//override caseTypeInt(TypeInt type) '''sc_int<«type.size»>'''

	override caseTypeUint(TypeUint type) '''unsigned «type.size.printInt»'''
	//override caseTypeUint(TypeUint type) '''sc_uint<«type.size»>'''

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

	/////////////////////////////////
	// Variables
	/////////////////////////////////
	override protected declare(Var v) '''«v.type.doSwitch» «v.compileIndexedName»«FOR dim : v.type.dimensions»[«dim»]«ENDFOR»'''

	def dispatch compileIndexedName(Def d) '''«IF !d.variable.needAllocation»«d.variable.name»«ELSE»(*«d.variable.name»)«ENDIF»'''

	def dispatch compileIndexedName(Use u) '''«IF !u.variable.needAllocation»«u.variable.name»«ELSE»(*«u.variable.name»)«ENDIF»'''

	def dispatch compileIndexedName(Var v) '''«IF !v.needAllocation»«v.name»«ELSE»(*«v.name»)«ENDIF»'''

	def protected boolean needAllocation(Var v) {
		return (v.type.list) && v.type.sizeInBits > 16384
	}

	def protected allocate(Var v) {
		destroyVarList.add(v)
		val TypeList t = v.type as TypeList
		'''
			«v.name» = («t.doSwitch» (*)«FOR dim : t.dimensions»[«dim»]«ENDFOR») malloc(«FOR dim : t.dimensions SEPARATOR "*"»«dim»«ENDFOR»*sizeof(«t.
				doSwitch»));
		'''
	}

	def protected declareTemporary(Var v) '''
		static «v.type.doSwitch» __«v.name»«FOR dim : v.type.dimensions»[«dim»]«ENDFOR» = «v.initialValue.doSwitch»;
	'''

	override protected declare(Procedure proc) '''«proc.returnType.doSwitch» «proc.name»(«proc.parameters.join(", ")[
		variable.declare]»);'''

	def protected declare(FSM fsm) '''«FOR state : fsm.states SEPARATOR ", "»__state_«state.name»«ENDFOR»'''

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
		«inst.target.compileIndexedName» = «inst.value.doSwitch»;
	'''

	override caseInstLoad(InstLoad inst) '''
		«inst.target.compileIndexedName» = «inst.source.compileIndexedName»«FOR index : inst.indexes»[«index.doSwitch»]«ENDFOR»;
	'''

	override caseInstCall(InstCall inst) '''
		«IF inst.print»
			native::println(«inst.arguments.printfArgs.join(", ")»);
		«ELSE»
			«IF inst.target != null»«inst.target.compileIndexedName» = «ENDIF»«IF (inst.procedure.native)»native::«(inst.
			procedure.compileAttribute("package") as List<String>).join("::")»::«ENDIF»«inst.procedure.name»(«inst.arguments.
			join(", ")[printCallArg]»);
		«ENDIF»
	'''

	def private printCallArg(Arg arg) {
		if (arg.byRef) {
			"&" + (arg as ArgByRef).use.compileIndexedName + (arg as ArgByRef).indexes.printArrayIndexes
		} else {
			val v = (arg as ArgByVal).value
			if (v instanceof ExprVarImpl)
				(v as ExprVarImpl).use.compileIndexedName
			else
				v.doSwitch
		}
	}

	override caseInstReturn(InstReturn inst) '''
		«IF procedure.eContainer instanceof Action»«IF (procedure.eContainer as Action).body.equals(procedure)»
			«FOR e : (procedure.eContainer as Action).outputPattern.portToVarMap»«e.compileWrite(
			(procedure.eContainer as Action).outputPattern)»«ENDFOR»
		«ENDIF»«ENDIF»
		«FOR v : destroyVarList SEPARATOR "\n"»free(«v.name»);«ENDFOR»
		«IF inst.value != null»return «inst.value.doSwitch»;«ENDIF»
	'''

	override caseInstStore(InstStore inst) '''
		«inst.target.compileIndexedName»«FOR index : inst.indexes»[«index.doSwitch»]«ENDFOR» = «inst.value.doSwitch»;
	'''

	//========================================
	//            FIFO Access
	//========================================
	def protected compileRead(Entry<Port, Var> e, Pattern p) '''
		«IF p.getNumTokens(e.key) == 1»
			__port_«e.key.name»[0]->get(«e.value.compileIndexedName»[0]);
		«ELSE»
			for(int __i=0;__i<«p.getNumTokens(e.key)»;__i++){
				__port_«e.key.name»[0]->get(«e.value.compileIndexedName»[__i]);
			}
		«ENDIF»
		__items_«e.key.name»[0] -= «p.getNumTokens(e.key)»;
	'''

	def protected compilePeek(Entry<Port, Var> e, Pattern p) '''
		«IF p.getNumTokens(e.key) == 1»
			__port_«e.key.name»[0]->peek(«e.value.compileIndexedName»[0]);
		«ELSE»
			for(int __i=0;__i<«p.getNumTokens(e.key)»;__i++){
				__port_«e.key.name»[0]->peek(«e.value.compileIndexedName»[__i]);
			}
		«ENDIF»
	'''

	def protected compileWrite(Entry<Port, Var> e, Pattern p) '''
		«IF p.getNumTokens(e.key) == 1»
			«FOR edge : outgoingPortMap.get(e.key) SEPARATOR "\n"»__port_«e.key.name»[«edge.compileAttribute("fifoId")»]->put(«e.
			value.compileIndexedName»[0]);«ENDFOR»
		«ELSE»
			for(int __i=0;__i<«p.getNumTokens(e.key)»;__i++){
				«FOR edge : outgoingPortMap.get(e.key) SEPARATOR "\n"»__port_«e.key.name»[«edge.compileAttribute("fifoId")»]->put(«e.
			value.compileIndexedName»[__i]);«ENDFOR»
			}
		«ENDIF»
		«FOR edge : outgoingPortMap.get(e.key) SEPARATOR "\n"»__rooms_«e.key.name»[«edge.compileAttribute("fifoId")»] -= «p.
			getNumTokens(e.key)»;«ENDFOR»
	'''

	//========================================
	//            Attributes
	//========================================
	def protected dispatch compileAttribute(Connection c, String name) {
		c.getAttribute(name).objectValue
	}

	def protected dispatch compileAttribute(Procedure p, String name) {
		p.getAttribute(name).objectValue
	}

	//========================================
	//            Scheduler
	//========================================
	def protected print(Action a, State s) '''
	(«FOR n : a.inputPattern.numTokensMap»__items_«n.key.name»[0] >= «n.value» && «ENDFOR»isSchedulable_«a.name»()) {
		«IF !a.outputPattern.empty»
		if(«FOR n : a.outputPattern.numTokensMap SEPARATOR " && "»«FOR e : outgoingPortMap.get(n.key) SEPARATOR " && "»__rooms_«n.
		key.name»[«e.compileAttribute("fifoId")»] >= «n.value»«ENDFOR»«ENDFOR») {
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

	def protected schedulerHasExecuted() ''''''

}
