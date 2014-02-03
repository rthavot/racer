package org.racer.backend.osci

import java.util.Map
import net.sf.orcc.df.Network

class CMakePrinter extends Printer {

	new(Map<String, Object> options) {
		super(options)
	}

	override content(Network network) '''
		CMAKE_MINIMUM_REQUIRED (VERSION 2.8)
		PROJECT («network.simpleName»)
		
		if(MSVC)
		SET(CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG /MTd /ZI /Ob0 /Od /RTC1 /vmg")
		SET(CMAKE_CXX_FLAGS_RELEASE "/MT /O2 /Ob2 /D NDEBUG /vmg")
		SET_PROPERTY( DIRECTORY PROPERTY COMPILE_DEFINITIONS _CRT_SECURE_NO_WARNINGS )
		endif()
		
		if(CMAKE_COMPILER_IS_GNUCXX)
		SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -ansi -pedantic -pthread -fsigned-char -fPIC")
		SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0 -g")
		SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")
		endif()
		
		SET(PROJECT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
		
		SET(LIB_DIR D:/eclipse/yace/trunk/eclipse/plugins/ch.epfl.stimm.yace.backend.osci/runtime)
		SET(TINYXML_INCLUDE_DIR ${LIB_DIR}/tinyxml/include)
		SET(YACE_INCLUDE_DIR ${LIB_DIR}/yace/include)
		
		SUBDIRS(${LIB_DIR})
		
		INCLUDE_DIRECTORIES(
			${SDL_INCLUDE_DIR}
			${SYSTEMC_INCLUDE_DIR}
			${TLM_INCLUDE_DIR}
			${TINYXML_INCLUDE_DIR}
			${YACE_INCLUDE_DIR}
			${PROJECT_DIR}
		)
		
		FILE ( GLOB PROJECT_INCLUDE_FILES ${PROJECT_DIR}/*.h )
		FILE ( GLOB PROJECT_SRC_FILES ${PROJECT_DIR}/*.cpp )
		
		# Configure ouput folder for generated binary
		SET(EXECUTABLE_OUTPUT_PATH ${CMAKE_SOURCE_DIR}/bin)
		
		ADD_EXECUTABLE («network.simpleName»
			${PROJECT_INCLUDE_FILES} ${PROJECT_SRC_FILES}
		)
		
		SET(libraries Yace TinyXml)
		SET(libraries ${libraries} ${SDL_LIBRARY} ${SYSTEMC_LIBRARY})
		SET(libraries ${libraries} ${CMAKE_THREAD_LIBS_INIT})
		
		TARGET_LINK_LIBRARIES(«network.simpleName» ${libraries})
	'''

}
