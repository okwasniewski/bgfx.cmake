# bgfx.cmake - bgfx building in cmake
# Written in 2017 by Joshua Brookover <joshua.al.brookover@gmail.com>

# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.

# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

cmake_minimum_required( VERSION 3.0 )
project( bgfx )

set_property( GLOBAL PROPERTY USE_FOLDERS ON )
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# __cplusplus value is not in sync with language version used. MVSC needs this flag to update it accordingly
# https://gitlab.kitware.com/cmake/cmake/-/issues/18837
if (MSVC)
    add_compile_options(/Zc:__cplusplus)
  endif()

if( APPLE AND NOT IOS )
	set( CMAKE_CXX_FLAGS "-ObjC++" )
endif()

option( BGFX_BUILD_TOOLS                "Build bgfx tools."                             OFF  )
option( BGFX_BUILD_EXAMPLES             "Build bgfx examples."                          ON  )
option( BGFX_INSTALL                    "Create installation target."                   OFF  )
option( BGFX_INSTALL_EXAMPLES           "Install examples and their runtimes."          OFF )
option( BGFX_CUSTOM_TARGETS             "Include convenience custom targets."           ON  )
option( BGFX_AMALGAMATED                "Amalgamated bgfx build for faster compilation" OFF )
option( BX_AMALGAMATED                  "Amalgamated bx build for faster compilation"   OFF )
option( BGFX_CONFIG_MULTITHREADED       "Build bgfx with multithreaded configuration"   ON )
option( BGFX_CONFIG_RENDERER_WEBGPU     "Enables the webgpu renderer"                   OFF )

set( BGFX_OPENGL_VERSION   ""       CACHE STRING "Specify minimum opengl version" )
set( BGFX_OPENGLES_VERSION ""       CACHE STRING "Specify minimum OpenGL ES version" )
set( BGFX_LIBRARY_TYPE     "STATIC" CACHE STRING "Linking type for library" )

set_property( CACHE BGFX_LIBRARY_TYPE PROPERTY STRINGS STATIC SHARED )

if( BGFX_LIBRARY_TYPE MATCHES "SHARED" )
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

if( NOT BX_DIR )
	set( BX_DIR "${CMAKE_CURRENT_SOURCE_DIR}/bx" CACHE STRING "Location of bx." )
elseif( NOT IS_ABSOLUTE "${BX_DIR}")
	get_filename_component(BX_DIR "${BX_DIR}" REALPATH BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
endif()
if( NOT BIMG_DIR )
	set( BIMG_DIR "${CMAKE_CURRENT_SOURCE_DIR}/bimg" CACHE STRING "Location of bimg." )
elseif( NOT IS_ABSOLUTE "${BIMG_DIR}")
	get_filename_component(BIMG_DIR "${BIMG_DIR}" REALPATH BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
endif()
if( NOT BGFX_DIR )
	set( BGFX_DIR "${CMAKE_CURRENT_SOURCE_DIR}/bgfx" CACHE STRING "Location of bgfx." )
elseif( NOT IS_ABSOLUTE "${BGFX_DIR}")
	get_filename_component(BGFX_DIR "${BGFX_DIR}" REALPATH BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
endif()

# sets project version from api ver / git rev
include( ${CMAKE_CURRENT_SOURCE_DIR}/cmake/version.cmake )

include( ${CMAKE_CURRENT_SOURCE_DIR}/cmake/shared.cmake )
include( ${CMAKE_CURRENT_SOURCE_DIR}/cmake/bx.cmake )
include( ${CMAKE_CURRENT_SOURCE_DIR}/cmake/bimg.cmake )
include( ${CMAKE_CURRENT_SOURCE_DIR}/cmake/bgfx.cmake )

if( BGFX_BUILD_TOOLS )
	include( ${CMAKE_CURRENT_SOURCE_DIR}/cmake/tools.cmake )
endif()

if( BGFX_BUILD_TOOLS OR BGFX_BUILD_EXAMPLES )
	include( ${CMAKE_CURRENT_SOURCE_DIR}/cmake/examples.cmake )
endif()

if( BGFX_INSTALL )
	include(GNUInstallDirs)

	# install bx
	install( TARGETS bx
		EXPORT bgfx-config
		ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} )
	install( DIRECTORY ${BX_DIR}/include DESTINATION . )

	# Configuration
	set(version_config "${generated_dir}/${PROJECT_NAME}ConfigVersion.cmake")
	set(project_config "${generated_dir}/${PROJECT_NAME}Config.cmake")
	set(TARGETS_EXPORT_NAME "${PROJECT_NAME}Targets")
	set(namespace "${PROJECT_NAME}::")

	# Include module with fuction 'write_basic_package_version_file'
	include(CMakePackageConfigHelpers)

	# Configure '<PROJECT-NAME>ConfigVersion.cmake'
	# Use:
	#   * PROJECT_VERSION
	if(${CMAKE_VERSION} VERSION_LESS "3.11.0")
		set(BGFX_COMPATIBILITY SameMajorVersion)
	else()
		set(BGFX_COMPATIBILITY SameMinorVersion)
	endif()
	write_basic_package_version_file(
		"${version_config}"
		VERSION ${PROJECT_VERSION}
		COMPATIBILITY ${BGFX_COMPATIBILITY}
	)

	# Configure '<PROJECT-NAME>Config.cmake'
	# Use variables:
	#   * TARGETS_EXPORT_NAME
	#   * PROJECT_NAME
	configure_package_config_file(
		"${CMAKE_CURRENT_SOURCE_DIR}/cmake/Config.cmake.in"
		"${project_config}"
		INSTALL_DESTINATION "${config_install_dir}"
	)

	install(FILES ${BGFX_DIR}/LICENSE DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/licences/${PROJECT_NAME})

	# install bgfx
	install( TARGETS bgfx
		EXPORT bgfx-config
		ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} )
	install( DIRECTORY ${BGFX_DIR}/include DESTINATION . )

	# install export
	install(
		EXPORT bgfx-config
		NAMESPACE bgfx::
		DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/bgfx)

	# install tools
	if( BGFX_BUILD_TOOLS )
		install( TARGETS shaderc
			EXPORT bgfx-config
			DESTINATION bin )
		install( TARGETS geometryc
			EXPORT bgfx-config
			DESTINATION bin )
		install( TARGETS texturec
			EXPORT bgfx-config
			DESTINATION bin )
		install( TARGETS texturev
			EXPORT bgfx-config
			DESTINATION bin )
	endif()

	# install examples
	if( BGFX_BUILD_EXAMPLES AND BGFX_INSTALL_EXAMPLES )
		install( DIRECTORY ${BGFX_DIR}/examples/runtime/ DESTINATION examples )
		foreach( EXAMPLE ${BGFX_EXAMPLES} )
			install( TARGETS example-${EXAMPLE} DESTINATION examples )
		endforeach()
	endif()
endif()
