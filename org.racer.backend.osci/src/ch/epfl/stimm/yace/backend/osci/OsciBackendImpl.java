package ch.epfl.stimm.yace.backend.osci;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import net.sf.orcc.backends.AbstractBackend;
import net.sf.orcc.backends.transform.DeadVariableRemoval;
import net.sf.orcc.backends.transform.Inliner;
import net.sf.orcc.backends.transform.LoopUnrolling;
import net.sf.orcc.backends.transform.ParameterImporter;
import net.sf.orcc.backends.transform.StoreOnceTransformation;
import net.sf.orcc.backends.util.Vectorizable;
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
import net.sf.orcc.util.OrccLogger;
import net.sf.orcc.util.Void;

import org.eclipse.core.resources.IFile;

import static ch.epfl.stimm.yace.backend.osci.OsciPathConstant.*;

public class OsciBackendImpl extends AbstractBackend {


	@Override
	protected void doInitializeOptions() {
		// Create empty folders
		new File(path + File.separator + BUILD).mkdirs();
		new File(path + File.separator + BIN).mkdirs();
	}

	@Override
	protected void doTransformActor(Actor actor) {
		List<DfSwitch<?>> transformations = new ArrayList<DfSwitch<?>>();

		transformations.add(new UnitImporter());
		transformations.add(new ParameterImporter());
		transformations.add(new DfVisitor<Void>(new Inliner(true, true)));

		transformations.add(new StoreOnceTransformation());
		transformations.add(new DeadProcedureElimination());
		transformations.add(new DfVisitor<Void>(new LoopUnrolling()));
		transformations.add(new DfVisitor<Void>(new DeadCodeElimination()));
		transformations.add(new DfVisitor<Void>(new DeadVariableRemoval()));
		

		for (DfSwitch<?> transformation : transformations) {
			transformation.doSwitch(actor);
		}

		// update "vectorizable" information
		Vectorizable.setVectorizableAttributs(actor);
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
		
		/*
		 * if (compiler.equals(SOFTWARE)) { SwBackendImpl swBackend = new
		 * SwBackendImpl(path); swBackend.setOptions(this.getAttributes());
		 * swBackend.doXdfCodeGeneration(network); } else if
		 * (compiler.equals(HARDWARE)) { HwBackendImpl hwBackend = new
		 * HwBackendImpl(path); hwBackend.setOptions(this.getAttributes());
		 * hwBackend.doXdfCodeGeneration(network); }
		 */
	}

	private boolean printNetwork(Network network) {
		return new OsciNetworkPrinter(options).print(path, network) > 0;
	}

	private boolean printRuntime(Network network) {
		return new OsciRuntimePrinter(options).print(path, network) > 0;
	}

	@Override
	protected void doVtlCodeGeneration(List<IFile> files) {
	}

	@Override
	protected boolean printInstance(Instance instance) {
		return new OsciInstancePrinter(options).print(path, instance) > 0;
	}

	@Override
	protected boolean printActor(Actor actor) {
		return new OsciInstancePrinter(options).print(path, actor) > 0;
	}

}
