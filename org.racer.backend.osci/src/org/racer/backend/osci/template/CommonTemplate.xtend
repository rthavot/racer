package org.racer.backend.osci.template

import net.sf.orcc.df.Actor
import net.sf.orcc.graph.Vertex

/*
 * The CommonTemplate is a standard Template without options
 * - Communication : tlm_fifo
 * - Type : non accurate
 */
class CommonTemplate {

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

}
