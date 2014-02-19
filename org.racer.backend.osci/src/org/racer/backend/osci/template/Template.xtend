package org.racer.backend.osci.template

import net.sf.orcc.df.Actor
import net.sf.orcc.df.Connection
import net.sf.orcc.df.Network

interface Template {

	def CharSequence declare(Connection c)

	def CharSequence declareLink(Connection c)

	def CharSequence declareSize(Connection c)

	
	/*  */
	
	def CharSequence printGlobals(Actor actor)
	
	def CharSequence printPorts(Actor actor)
	
	def CharSequence printStatuses(Actor actor)
	
	def CharSequence printControls(Actor actor)
	
	def CharSequence printActions(Actor actor)
	
	def CharSequence printInitializer(Actor actor)
	
	def CharSequence printScheduler(Actor actor)
	
	def CharSequence printConstructor(Actor actor)
	
	/* */
	
	def CharSequence printConstructor(Network network)
	
	
}
