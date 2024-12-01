cmake_minimum_required(VERSION 3.20)

project(openfx-standard VERSION 1.5.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(WIN32)
    add_compile_definitions(WINDOWS NOMINMAX WIN64)
    set(OS_VAR "windows")
    set(OFX_ARCH_NAME "Win64")
endif()

add_definitions(-DOFX_SUPPORTS_OPENGLRENDER)

set(OFX_HEADERS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)

add_library(OpenFx-standard INTERFACE)
target_include_directories(OpenFx-standard
    INTERFACE
    $<BUILD_INTERFACE:${OFX_HEADERS_DIR}>
    $<INSTALL_INTERFACE:include/openfx-standard>
)

set(OFX_SUPPORT_HEADERS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Support/include)

add_library(OfxSupport-standard STATIC
    Support/Library/ofxsCore.cpp
    Support/Library/ofxsImageEffect.cpp
    Support/Library/ofxsInteract.cpp
    Support/Library/ofxsLog.cpp
    Support/Library/ofxsMultiThread.cpp
    Support/Library/ofxsParams.cpp
    Support/Library/ofxsProperty.cpp
    Support/Library/ofxsPropertyValidation.cpp
)
target_include_directories(OfxSupport-standard
    PUBLIC
    $<BUILD_INTERFACE:${OFX_HEADERS_DIR}>
    $<BUILD_INTERFACE:${OFX_SUPPORT_HEADERS_DIR}>
    $<INSTALL_INTERFACE:include/openfx-standard>
)
target_link_libraries(OfxSupport-standard INTERFACE OpenFx-standard)
target_compile_features(OfxSupport-standard PUBLIC cxx_std_11)

set(OFX_HOSTSUPPORT_HEADER_DIR ${CMAKE_CURRENT_SOURCE_DIR}/HostSupport/include)
set(OFX_HOSTSUPPORT_LIBRARY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/HostSupport/src)
file(GLOB_RECURSE OFX_HOSTSUPPORT_HEADER_FILES "${OFX_HOSTSUPPORT_HEADER_DIR}/*.h")
file(GLOB_RECURSE OFX_HOSTSUPPORT_LIBRARY_FILES "${OFX_HOSTSUPPORT_LIBRARY_DIR}/*.cpp")
file(GLOB_RECURSE OFX_HEADER_FILES "${OFX_HEADERS_DIR}/*.h")

find_package(expat CONFIG REQUIRED)

add_library(OfxHost STATIC
	${OFX_HEADER_FILES}
	${OFX_HOSTSUPPORT_HEADER_FILES}
	${OFX_HOSTSUPPORT_LIBRARY_FILES})

set_target_properties(OfxHost PROPERTIES LINKER_LANGUAGE CXX)
if(NOT MSVC)
	set_target_properties(OfxHost PROPERTIES COMPILE_FLAGS "-fPIC")
endif()

target_link_libraries(OfxHost PUBLIC expat::expat)

target_include_directories(OfxHost PUBLIC
    $<BUILD_INTERFACE:${OFX_HEADERS_DIR}>
	$<BUILD_INTERFACE:${OFX_HOSTSUPPORT_HEADER_DIR}>
	$<BUILD_INTERFACE:${expat_INCLUDE_DIR}>
    $<INSTALL_INTERFACE:include/openfx-standard>
)

install(
    TARGETS OpenFx-standard OfxSupport-standard OfxHost
    EXPORT openfx-export
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(
    EXPORT openfx-export
    FILE unofficial-openfxTarget.cmake
    NAMESPACE unofficial::openfx::
    DESTINATION "share/unofficial-openfx"
)

file(GLOB OFX_HEADERS "${OFX_HEADERS_DIR}/*.h" "${OFX_SUPPORT_HEADERS_DIR}/*.h"  "${OFX_HOSTSUPPORT_HEADER_DIR}/*.h")
install(FILES ${OFX_HEADERS}
    DESTINATION include/openfx-standard
)

include(CMakePackageConfigHelpers)

configure_package_config_file(${OPENFX_CONFIG_TEMPLATE_PATH}
  "${CMAKE_CURRENT_BINARY_DIR}/unofficial-openfxConfig.cmake"
  INSTALL_DESTINATION "share/unofficial-openfx"
  NO_SET_AND_CHECK_MACRO
  NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/unofficial-openfxConfig.cmake
  DESTINATION share/unofficial-openfx
)