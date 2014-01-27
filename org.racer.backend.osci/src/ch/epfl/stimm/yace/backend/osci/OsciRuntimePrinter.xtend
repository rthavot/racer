package ch.epfl.stimm.yace.backend.osci

import java.io.File
import java.util.Map
import net.sf.orcc.df.Network
import net.sf.orcc.util.OrccUtil

import static org.racer.backend.osci.OsciPathConstant.*

class OsciRuntimePrinter {

	new(Map<String, Object> options) {
	}

	def print(String targetFolder, Network network) {
		val sourceFile = new File(targetFolder, SRC + File::separator + "__runtime.cpp")

		val source = sourceContent(network)
		OrccUtil::printFile(source, sourceFile)
		return 0
	}

	def sourceContent(Network network) '''
		#include <YACE.h>
		#include "«network.simpleName».h"
		
		#define sc_main	SDL_main
		
		yace::util::GetOpt opt;
		
		int sc_main(int argc, char* argv[]){
			opt.parse(argc,argv);
			opt.getOptions();
		
			sc_signal<bool>  reset_n;
			sc_clock  clock_100("clk@100Hz", 10.0 ,SC_NS);
			«network.simpleName» «network.simpleName»("top");
		
			«network.simpleName».__pin_clock(clock_100);
			«network.simpleName».__pin_reset_n(reset_n);
		
			reset_n.write(false);
			sc_start(111, SC_NS);
			reset_n.write(true);
			sc_start();
		
			return 0;
		}
	'''

}
