package org.racer.backend.osci.template

import java.util.LinkedList
import java.util.List
import net.sf.orcc.backends.CommonPrinter
import net.sf.orcc.backends.ir.BlockFor
import net.sf.orcc.df.Connection
import net.sf.orcc.df.Port
import net.sf.orcc.ir.Arg
import net.sf.orcc.ir.ArgByRef
import net.sf.orcc.ir.ArgByVal
import net.sf.orcc.ir.BlockBasic
import net.sf.orcc.ir.BlockIf
import net.sf.orcc.ir.BlockWhile
import net.sf.orcc.ir.Def
import net.sf.orcc.ir.ExprString
import net.sf.orcc.ir.InstAssign
import net.sf.orcc.ir.InstCall
import net.sf.orcc.ir.InstLoad
import net.sf.orcc.ir.InstReturn
import net.sf.orcc.ir.InstStore
import net.sf.orcc.ir.Instruction
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
import net.sf.orcc.df.FSM
import net.sf.orcc.graph.Vertex
import net.sf.orcc.df.Actor

/*
 * The CommonTemplate is a standard Template without options
 * - Communication : tlm_fifo
 * - Type : non accurate
 */
abstract class CommonTemplate extends CommonPrinter {

	protected List<Var> destroyVarList = newArrayList()
	private final Printer printer;

	//========================================
	//          Constructor
	//========================================
	new(Printer p) {
		printer = p
	}

	def protected static getActorName(Vertex v) '''«v.getAdapter(Actor).name»'''

	//========================================
	//          Get from printer
	//========================================
	def protected getOutgoingPortMap() {
		return printer.outgoingPortMap
	}

	def protected beginSection(String section) {
		return Printer::beginSection(section)
	}

	def protected wrap(CharSequence seq, String separator, Integer limit) {
		return Printer::wrap(seq, separator, limit)
	}

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
		LABEL(«block.attribute("label")»)
		for («block.init.join(", ")['''«toExpression»''']» ; «block.condition.doSwitch» ; «block.
			step.join(", ")['''«toExpression»''']») {
			«FOR contentBlock : block.blocks»«contentBlock.doSwitch»«ENDFOR»
		}
	'''

	/**
	 * This helper return a representation of a given instruction without
	 * trailing whitespace and semicolon
	 */
	def private toExpression(Instruction instruction) {
		instruction.doSwitch.toString.replaceAll("([^;]+);(\\s+)?", "$1")
	}

	//========================================
	//             Types
	//========================================
	def protected typing(Procedure p) '''«p.returnType.doSwitch»'''

	def protected typing(Port p) '''«p.type.doSwitch»'''

	def protected typing(Var v) '''«v.type.doSwitch»'''

	override caseTypeBool(TypeBool type) '''bool'''

	override caseTypeFloat(TypeFloat type) '''float'''

	override caseTypeString(TypeString type) '''std::string'''

	override caseTypeInt(TypeInt type) '''«IF (!printer.scType)»«type.size.printInt»«ELSE»sc_int<«type.size»>«ENDIF»'''

	override caseTypeUint(TypeUint type) '''«IF (!printer.scType)»unsigned «type.size.printInt»«ELSE»sc_uint<«type.size»>«ENDIF»'''

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
	//             Variables
	//========================================
	def protected declare(Var v) '''
		«v.typing» «v.indexedName»«FOR dim : v.type.dimensions»[«dim»]«ENDFOR»;
	'''

	def protected declareTemporary(Var v) '''
		«v.typing» __«v.name»«FOR dim : v.type.dimensions»[«dim»]«ENDFOR» = «v.initialValue.doSwitch»;
	'''

	def protected dispatch indexedName(Def d) '''«IF !d.variable.needAllocation»«d.variable.name»«ELSE»(*«d.variable.
		name»)«ENDIF»'''

	def protected dispatch indexedName(Use u) '''«IF !u.variable.needAllocation»«u.variable.name»«ELSE»(*«u.variable.
		name»)«ENDIF»'''

	def protected dispatch indexedName(Var v) '''«IF !v.needAllocation»«v.name»«ELSE»(*«v.name»)«ENDIF»'''

	def protected boolean needAllocation(Var v) {
		return (v.type.list) && v.type.sizeInBits > 16384
	}

	//========================================
	//            Instructions
	//========================================
	override caseInstAssign(InstAssign inst) '''
		«inst.target.indexedName» = «inst.value.doSwitch»;
	'''

	override caseInstLoad(InstLoad inst) '''
		«inst.target.indexedName» = «inst.source.indexedName»«FOR index : inst.indexes»[«index.doSwitch»]«ENDFOR»;
	'''

	override caseInstStore(InstStore inst) '''
		«inst.target.indexedName»«FOR index : inst.indexes»[«index.doSwitch»]«ENDFOR» = «inst.value.doSwitch»;
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

	override caseInstReturn(InstReturn inst) '''
		«IF inst.value != null»return «inst.value.doSwitch»;«ENDIF»
	'''

	//========================================
	//      Miscellaneous for CallInst
	//========================================
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

	//========================================
	//            Attributes
	//========================================
	def protected dispatch attribute(Connection c, String name) {
		return c.getAttribute(name).objectValue
	}

	def protected dispatch attribute(Procedure p, String name) {
		return p.getAttribute(name).objectValue
	}

	def protected dispatch attribute(BlockFor b, String name) {
		return b.getAttribute(name).stringValue
	}

	//========================================
	//            FSM
	//========================================
	def protected declare(FSM fsm) '''«FOR state : fsm.states SEPARATOR ", "»__state_«state.name»«ENDFOR»'''

}
