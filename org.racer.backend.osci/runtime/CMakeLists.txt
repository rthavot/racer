cmake_minimum_required (VERSION 2.8)

# Common packages required

FIND_PATH(SYSTEMC_INCLUDE_DIR systemc.h
  HINTS $ENV{SYSTEMCDIR}
  PATH_SUFFIXES src
)
#MESSAGE("SYSTEMC_INCLUDE_DIR is ${SYSTEMC_INCLUDE_DIR}")

#FIND_PATH(ORCC_INCLUDE_DIR orcc.h
#  HINTS $ENV{ORCC-OSCI}
#  PATH_SUFFIXES orcc orcc/include
#)
#MESSAGE("ORCC_INCLUDE_DIR is ${ORCC_INCLUDE_DIR}")

FIND_PATH(TLM_INCLUDE_DIR tlm.h
  HINTS
  $ENV{TLMDIR}
  PATH_SUFFIXES include include/tlm
)
#MESSAGE("TLM_INCLUDE_DIR is ${TLM_INCLUDE_DIR}")

FIND_LIBRARY(SYSTEMC_LIBRARY
  NAMES SystemC
  HINTS $ENV{SYSTEMCDIR}
  PATH_SUFFIXES lib64 lib
)

FIND_PACKAGE(SDL REQUIRED)

INCLUDE_DIRECTORIES(
	${SDL_INCLUDE_DIR}
	${SYSTEMC_INCLUDE_DIR}
	${TLM_INCLUDE_DIR}
)


file ( GLOB_RECURSE tinyxml_source_files tinyxml/* )
add_library (TinyXml STATIC ${tinyxml_source_files})

file ( GLOB_RECURSE yace_source_files yace/* )
add_library (Yace STATIC ${yace_source_files})
