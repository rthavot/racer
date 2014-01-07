package ch.epfl.stimm.yace.backend.osci

import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.PrintStream
import java.util.Date
import net.sf.orcc.backends.CommonPrinter
import net.sf.orcc.df.Actor
import net.sf.orcc.df.Connection
import net.sf.orcc.df.Instance
import net.sf.orcc.df.Network
import net.sf.orcc.ir.ArgByRef
import net.sf.orcc.ir.ArgByVal
import net.sf.orcc.ir.BlockBasic
import net.sf.orcc.ir.BlockIf
import net.sf.orcc.ir.BlockWhile
import net.sf.orcc.ir.Def
import net.sf.orcc.ir.ExprBinary
import net.sf.orcc.ir.ExprBool
import net.sf.orcc.ir.ExprFloat
import net.sf.orcc.ir.ExprInt
import net.sf.orcc.ir.ExprList
import net.sf.orcc.ir.ExprString
import net.sf.orcc.ir.ExprUnary
import net.sf.orcc.ir.ExprVar
import net.sf.orcc.ir.Expression
import net.sf.orcc.ir.InstAssign
import net.sf.orcc.ir.InstCall
import net.sf.orcc.ir.InstLoad
import net.sf.orcc.ir.InstReturn
import net.sf.orcc.ir.InstStore
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
import org.eclipse.emf.ecore.EObject

class StandardPrinter extends CommonPrinter {

	protected int branch;
	protected int precedence;

	new() {
		branch = 0
		precedence = Integer::MAX_VALUE
	}

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

	def public dispatch boolean print(String fileName, String path, Network network) {
		var String file = path + File::separator + fileName;
		try {
			var PrintStream ps = new PrintStream(new FileOutputStream(file));
			ps.print(network.compileNetwork);
			ps.close();
			return true;
		} catch (FileNotFoundException e) {
		}
		return false;
	}

	def public dispatch boolean print(String fileName, String path, Instance instance) {
		var String file = path + File::separator + fileName;
		try {
			var PrintStream ps = new PrintStream(new FileOutputStream(file));
			ps.print(instance.compileInstance);
			ps.close();
			return true;
		} catch (FileNotFoundException e) {
		}
		return false;
	}

	def public dispatch boolean print(String fileName, String path, Actor actor) {
		var String file = path + File::separator + fileName;
		try {
			var PrintStream ps = new PrintStream(new FileOutputStream(file));
			ps.print(actor.compileActor);
			ps.close();
			return true;
		} catch (FileNotFoundException e) {
		}
		return false;
	}

	def protected compileNetwork(Network network) ''''''

	def protected compileInstance(Instance instance) ''''''

	def protected compileActor(Actor actor) ''''''

	def protected beginSection(String section) '''
		////////////////////////////////////////////////////////////////////////////////
		// «section»
	'''

	def protected compileDate() '''«new Date()»'''

	def protected endSection(String section) '''
		«'\n'»
	'''

	override caseProcedure(Procedure procedure) '''
		«FOR node : procedure.blocks»«node.doSwitch»«ENDFOR»
	'''

	override caseBlockBasic(BlockBasic node) '''
		«FOR inst : node.instructions»«inst.doSwitch»«ENDFOR»
	'''

	override caseBlockIf(BlockIf node) '''
		if(«node.condition.doSwitch») {
			«FOR then : node.thenBlocks»«then.doSwitch»«ENDFOR»	
		} «IF !node.elseBlocks.empty»else {
				«FOR els : node.elseBlocks»«els.doSwitch»«ENDFOR»
		}«ENDIF»
		«node.joinBlock.doSwitch»
	'''

	override caseBlockWhile(BlockWhile node) '''
		while(«node.condition.doSwitch») {
			«FOR w : node.blocks»«w.doSwitch»«ENDFOR»
		}
		«node.joinBlock.doSwitch»
	'''

	override caseInstAssign(InstAssign inst) '''
		«inst.target.compileIndexedName» = «inst.value.doSwitch»;
	'''

	override caseInstCall(InstCall inst) '''
		«IF inst.target != null»«inst.target.compileIndexedName» = «ENDIF»«inst.compileCall»;
	'''

	def protected compileCall(InstCall inst) '''«inst.procedure.name»(«FOR arg : inst.parameters SEPARATOR ", "»«arg.
		compileArg»«ENDFOR»)'''

	override caseInstLoad(InstLoad inst) '''
		«inst.target.compileIndexedName» = «inst.source.compileIndexedName»«FOR index : inst.indexes»[«index.doSwitch»]«ENDFOR»;
	'''

	override caseInstReturn(InstReturn inst) '''
		«IF inst.value != null»return «inst.value.doSwitch»;«ENDIF»
	'''

	override caseInstStore(InstStore inst) '''
		«inst.target.compileIndexedName»«FOR index : inst.indexes»[«index.doSwitch»]«ENDFOR» = «inst.value.doSwitch»;
	'''

	override caseTypeBool(TypeBool type) '''bool'''

	override caseTypeFloat(TypeFloat type) '''float'''

	override caseTypeString(TypeString type) '''std::string'''

	override caseTypeInt(TypeInt type) '''«type.size.printInt»'''

	override caseTypeUint(TypeUint type) '''unsigned «type.size.printInt»'''

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

	override caseExprBinary(ExprBinary expr) '''«IF expr.op.needsParentheses(precedence, branch)»(«expr.e1.
		doSwitch(expr.op.precedence, 0)» «expr.op.text» «expr.e2.doSwitch(expr.op.precedence, 1)»)«ELSE»«expr.e1.
		doSwitch(expr.op.precedence, 0)» «expr.op.text» «expr.e2.doSwitch(expr.op.precedence, 1)»«ENDIF»'''

	override caseExprBool(ExprBool expr) '''«String::valueOf(expr.value)»'''

	override caseExprFloat(ExprFloat expr) '''«String::valueOf(expr.value)»'''

	override caseExprInt(ExprInt expr) '''«String::valueOf(expr.value)»'''

	override caseExprList(ExprList expr) '''{«FOR v : expr.value SEPARATOR ", "»«v.doSwitch»«ENDFOR»}'''

	override caseExprString(ExprString expr) '''"«String::valueOf(expr.value)»"'''

	override caseExprUnary(ExprUnary expr) '''«expr.op.text» «expr.expr.doSwitch(Integer::MIN_VALUE, branch)»'''

	override caseExprVar(ExprVar expr) '''«expr.use.compileIndexedName»'''

	/*override doSwitch(EObject eObject) {
		if (eObject == null) {
			return "null";
		} else {
			return super.doSwitch(eObject);
		}
	}*/

	def protected doSwitch(Expression expression, int newPrecedence, int newBranch) {
		var oldBranch = branch
		var oldPrecedence = precedence
		branch = newBranch
		precedence = newPrecedence
		var result = expression.doSwitch
		precedence = oldPrecedence
		branch = oldBranch
		return result;
	}

	def protected dispatch compileIndexedName(Def d) '''«d.variable.name»'''

	def protected dispatch compileIndexedName(Use u) '''«u.variable.name»'''

	def protected dispatch compileIndexedName(Var v) '''«v.name»'''

	def protected dispatch compileArg(ArgByRef arg) '''«arg.use.compileIndexedName»«FOR index : arg.indexes»[«index.
		doSwitch»]«ENDFOR»'''

	def protected dispatch compileArg(ArgByVal arg) '''«arg.value.doSwitch»'''

	def protected dispatch compileAttribute(Connection c, String name) {
		c.getAttribute(name).objectValue
	}

	def protected dispatch compileAttribute(Procedure p, String name) {
		p.getAttribute(name).objectValue
	}

}
