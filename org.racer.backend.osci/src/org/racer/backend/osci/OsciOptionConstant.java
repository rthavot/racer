package org.racer.backend.osci;

public interface OsciOptionConstant {

	static final String OptionPackage = "org.racer.backend.osci.option.";
	
	static final String SC_TYPE = OptionPackage +"sctype";
	
	static final String INTER_ACTOR_COMMUNICATION = OptionPackage +"iac";
	
	final static String IAC_FIFO = "FIFO";
	
	final static String IAC_SM = "Shared Memory";
	
	final static String IAC_CM = "Cached Memory";
	
}
