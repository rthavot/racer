package org.racer.backend.osci

import net.sf.orcc.df.Actor
import net.sf.orcc.df.Connection
import net.sf.orcc.df.FSM
import net.sf.orcc.df.Port
import net.sf.orcc.ir.Procedure
import net.sf.orcc.ir.Var

interface Template {

	def CharSequence declare(Var v)

	def CharSequence declare(Procedure p)

	def CharSequence declare(FSM v)

	def CharSequence declare(Port p)

	def CharSequence declareStatus(Port p)

	def CharSequence updateStatus(Port p)

	def CharSequence declare(Connection c)

	def CharSequence declareLink(Connection c)

	def CharSequence declareSize(Connection c)

	def CharSequence printProcedure(Procedure p)

	def CharSequence printInitializer(Actor a)

	def CharSequence printScheduler(Actor a)
	
	def CharSequence printConstructor(Actor a)
}
