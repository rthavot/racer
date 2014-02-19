package org.racer.backend.osci;

import static org.racer.backend.osci.OsciConstant.PATH_BIN;
import static org.racer.backend.osci.OsciConstant.PATH_BUILD;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import net.sf.orcc.backends.AbstractBackend;
import net.sf.orcc.backends.transform.DeadVariableRemoval;
import net.sf.orcc.backends.transform.Inliner;
import net.sf.orcc.backends.transform.ParameterImporter;
import net.sf.orcc.backends.transform.StoreOnceTransformation;
import net.sf.orcc.backends.util.Alignable;
import net.sf.orcc.df.Actor;
import net.sf.orcc.df.Instance;
import net.sf.orcc.df.Network;
import net.sf.orcc.df.transform.ArgumentEvaluator;
import net.sf.orcc.df.transform.Instantiator;
import net.sf.orcc.df.transform.NetworkFlattener;
import net.sf.orcc.df.transform.UnitImporter;
import net.sf.orcc.df.util.DfSwitch;
import net.sf.orcc.df.util.DfVisitor;
import net.sf.orcc.ir.transform.DeadCodeElimination;
import net.sf.orcc.ir.transform.DeadProcedureElimination;
import net.sf.orcc.ir.util.AbstractIrVisitor;
import net.sf.orcc.util.OrccLogger;
import net.sf.orcc.util.Void;

import org.eclipse.core.resources.IFile;
import org.racer.backend.osci.transform.ForLoopTransformation;

public class OsciBackendImpl extends AbstractBackend {

	@Override
	protected void doInitializeOptions() {
		// Create empty folders
		new File(path + File.separator + PATH_BUILD).mkdirs();
		new File(path + File.separator + PATH_BIN).mkdirs();
	}

	@Override
	protected void doTransformActor(Actor actor) {
		List<DfSwitch<?>> tfList = new ArrayList<DfSwitch<?>>();

		tfList.add(new UnitImporter());
		tfList.add(new ParameterImporter());
		tfList.add(new DfVisitor<Void>(new Inliner(true, true)));

		tfList.add(new StoreOnceTransformation());
		tfList.add(new DeadProcedureElimination());
		//transformations.add(new DfVisitor<Void>(new LoopUnrolling()));
		
		tfList.add(new ForLoopTransformation());
		
		tfList.add(new DfVisitor<Void>(new DeadCodeElimination()));
		tfList.add(new DfVisitor<Void>(new DeadVariableRemoval()));

		for (DfSwitch<?> tf : tfList) {
			tf.doSwitch(actor);
		}

		// update "vectorizable" information
		Alignable.setAlignability(actor);
	}

	protected void doTransformNetwork(Network network) {
		OrccLogger.traceln("Instantiating...");
		new Instantiator(true, fifoSize).doSwitch(network);
		OrccLogger.traceln("Flattening...");
		new NetworkFlattener().doSwitch(network);
		new UnitImporter().doSwitch(network);

		new ArgumentEvaluator().doSwitch(network);
	}

	@Override
	protected void doXdfCodeGeneration(Network network) {

		doTransformNetwork(network);

		transformActors(network.getAllActors());

		network.computeTemplateMaps();

		// print instances
		printChildren(network);

		// print network
		OrccLogger.trace("Printing network...\n");
		printNetwork(network);

		// print Runtime
		OrccLogger.trace("Printing runtime...\n");
		printRuntime(network);

		// print Runtime
		OrccLogger.trace("Printing cmake...\n");
		printCMake(network);

	}

	private boolean printNetwork(Network network) {
		String targetPath = path + File.separator + network.getSimpleName() + ".h";
		return new NetworkPrinter(options).print(targetPath, network) > 0;
		//return new OsciNetworkPrinter(options).print(path, network) > 0;
	}

	private boolean printRuntime(Network network) {
		String targetPath = path + File.separator + "runtime.cpp";
		return new RuntimePrinter(options).print(targetPath, network) > 0;
		//return new OsciRuntimePrinter(options).print(path, network) > 0;
	}

	private boolean printCMake(Network network) {
		String targetPath = path + File.separator + "CMakeLists.txt";
		return new CMakePrinter(options).print(targetPath, network) > 0;
		//return new OsciCMakePrinter(options).print(path, network) > 0;
	}

	@Override
	protected void doVtlCodeGeneration(List<IFile> files) {
	}

	@Override
	protected boolean printInstance(Instance instance) {
		return printActor(instance.getActor());
	}

	@Override
	protected boolean printActor(Actor actor) {
		String targetPath = path + File.separator + actor.getName() + ".h";
		return new InstancePrinter(options).print(targetPath, actor) > 0;
		// return new OsciInstancePrinter(options).print(path, actor) > 0;
	}

}
