package org.racer.backend.osci;

public interface OsciConstant {

	//========================================
	//             PATHS
	//========================================
	
	public static String PATH_BIN = "bin";
	
	public static String PATH_BUILD = "build";
	
	//========================================
	//             OPTIONS
	//========================================
	
	static final String OPTION_PACKAGE = "org.racer.backend.osci.option.";
	
	// TYPE
	
	static final String OPTION_SC_TYPE = OPTION_PACKAGE +"sctype";
	
	// INTER ACTOR COMMUNICATION
	
	static final String OPTION_IAC = OPTION_PACKAGE +"iac"; 
	
	final static String OPTION_IAC_FIFO = "FIFO";
	
	final static String OPTION_IAC_SM = "Shared Memory";
	
	final static String OPTION_IAC_CM = "Cached Memory";
	
}
