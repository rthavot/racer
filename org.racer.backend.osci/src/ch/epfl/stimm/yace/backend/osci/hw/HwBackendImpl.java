package ch.epfl.stimm.yace.backend.osci.hw;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import net.sf.orcc.backends.AbstractBackend;
import net.sf.orcc.backends.c.InstancePrinter;
import net.sf.orcc.backends.transform.Inliner;
import net.sf.orcc.backends.transform.ParameterImporter;
import net.sf.orcc.backends.transform.StoreOnceTransformation;
import net.sf.orcc.df.Actor;
import net.sf.orcc.df.Instance;
import net.sf.orcc.df.Network;
import net.sf.orcc.df.transform.Instantiator;
import net.sf.orcc.df.transform.NetworkFlattener;
import net.sf.orcc.df.transform.UnitImporter;
import net.sf.orcc.df.util.DfSwitch;
import net.sf.orcc.df.util.DfVisitor;
import net.sf.orcc.ir.transform.DeadCodeElimination;
import net.sf.orcc.ir.transform.DeadProcedureElimination;
import net.sf.orcc.util.Void;
import net.sf.orcc.backends.transform.DeadVariableRemoval;

import org.eclipse.core.resources.IFile;

import ch.epfl.stimm.yace.backend.osci.CMakePrinter;
import ch.epfl.stimm.yace.backend.osci.OsciRuntimePrinter;

public class HwBackendImpl extends AbstractBackend {

	/**
	 * Path to target "src" folder
	 */
	protected String srcPath;
	

	@Override
	public void doInitializeOptions() {
		// TODO Auto-generated method stub
		srcPath = path + File.separator + "src";
	}

	@Override
	public void doTransformActor(Actor actor) {

		List<DfSwitch<?>> transformations = new ArrayList<DfSwitch<?>>();
		
		transformations.add(new UnitImporter());
		transformations.add(new ParameterImporter());
		transformations.add(new DfVisitor<Void>(new Inliner(true, true)));
		
		transformations.add(new StoreOnceTransformation());
		transformations.add(new DfVisitor<Void>(new DeadCodeElimination()));
		transformations.add(new DfVisitor<Void>(new DeadVariableRemoval()));
		transformations.add(new DeadProcedureElimination());

		for (DfSwitch<?> transformation : transformations) {
			transformation.doSwitch(actor);
		}

	}

	@Override
	public void doVtlCodeGeneration(List<IFile> files) {
		// TODO Auto-generated method stub
	}

	@Override
	public void doXdfCodeGeneration(Network network) {
		transformActors(network.getAllActors());
		network = doTransformNetwork(network);
		printChildren(network);
		//printNetwork(network);
		printCMake(network);
		//printRuntime(network);
	}

	final private Network doTransformNetwork(Network network) {
		new Instantiator(false, fifoSize).doSwitch(network);
		new NetworkFlattener().doSwitch(network);
		network.computeTemplateMaps();
		return network;
	}

	@Override
	protected boolean printInstance(Instance instance) {
		return new InstancePrinter(options).print(srcPath, instance) > 0;
	}

	/*private boolean printNetwork(Network network) {
		return new HwNetworkPrinter().print(network.getSimpleName() + ".h",
				path, network);
	}*/

	private boolean printCMake(Network network) {
		return new CMakePrinter().print("CMakeLists.txt", path, network);
	}

	/*private boolean printRuntime(Network network) {
		/*return new OsciRuntimePrinter().print(network.getSimpleName()
				+ ".runtime.cpp", path, network);
	}*/

}
