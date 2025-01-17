add_subdirectory(passes)

# TODO Just do this here instead of in passes.
find_package(LLVM 13 CONFIG)

if (LLVM_FOUND)
  message(STATUS "LLVM_VERSION_MAJOR: ${LLVM_VERSION_MAJOR}")
  message(STATUS "LLVM_VERSION_MINOR: ${LLVM_VERSION_MINOR}")
  message(STATUS "LLVM_VERSION_PATCH: ${LLVM_VERSION_PATCH}")
else()
  # message(FATAL_ERROR "You need LLVM >=10 to build this (found LLVM ${LLVM_VERSION_MAJOR}).")
endif()

add_definitions(${LLVM_DEFINITIONS})
include_directories(${LLVM_INCLUDE_DIRS})
add_library(LLVMPassConfig INTERFACE IMPORTED)
set_target_properties(LLVMPassConfig PROPERTIES
  INTERFACE_COMPILE_OPTIONS "-fno-rtti" #-fpic
  INTERFACE_INCLUDE_DIRECTORIES "${LLVM_INCLUDE_DIRS}"
  INTERFACE_LINK_DIRECTORIES "${LLVM_LIBRARY_DIRS}"
  INTERFACE_COMPILE_DEFINITIONS "LLVM_VERSION_MAJOR=${LLVM_VERSION_MAJOR};LLVM_VERSION_MINOR=${LLVM_VERSION_MINOR}"
  # INTERFACE_LINK_OPTIONS "-Wl,-znodelete"
  )

set(POLY_DIR "polytracker")
set(TAINT_DIR "taint_sources")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
if (XRAY_ON)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fxray-instrument -fxray-instruction-threshold=1 -Wall -Werror -stdlib=libc++ -static -I${POLYTRACK_CXX_INCLUDE} -g -O3")
else()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -static -I${POLYTRACK_CXX_INCLUDE} -I/polytracker-llvm/llvm/include -I/polytracker_clang/include -std=c++14 -fno-exceptions -fno-rtti -D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Werror -g -O3")
  message(STATUS "Cmake flags: " ${CMAKE_CXX_FLAGS})
  endif()
set(CMAKE_EXE_LINKER_FLAGS "-stdlib=libc++ -L/polytracker_clang/lib -L${POLYTRACK_CXX_LIB} -Wl,--start-group,-lc++abi")

set(POLY_SOURCES
${POLY_DIR}/main.cpp 
${POLY_DIR}/logging.cpp 
${POLY_DIR}/taint.cpp
${POLY_DIR}/output.cpp 
${POLY_DIR}/tablegen.cpp 
${POLY_DIR}/polytracker.cpp
${POLY_DIR}/sqlite3.c
)

set (TAINT_SOURCES 
${TAINT_DIR}/taint_sources.cpp
${TAINT_DIR}/string_taints.cpp 
${TAINT_DIR}/memory_taints.cpp
${TAINT_DIR}/write_taints.cpp
)

add_library(Polytracker STATIC 
${POLY_SOURCES} 
${TAINT_SOURCES} 
)
target_link_libraries(Polytracker LLVMPassConfig)
install (TARGETS Polytracker DESTINATION ${POLYTRACK_LIB_DIR})
