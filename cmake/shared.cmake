# bgfx.cmake - bgfx building in cmake
# Written in 2017 by Joshua Brookover <joshua.al.brookover@gmail.com>

# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.

# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

add_library( bgfx-vertexdecl INTERFACE )
configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/generated/vertexdecl.cpp.in
                ${CMAKE_CURRENT_BINARY_DIR}/generated/vertexdecl.cpp )
target_sources( bgfx-vertexdecl INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/generated/vertexdecl.cpp )
target_include_directories( bgfx-vertexdecl INTERFACE ${BGFX_DIR}/include )

add_library( bgfx-shader-spirv INTERFACE )
configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/generated/shader_spirv.cpp.in
                ${CMAKE_CURRENT_BINARY_DIR}/generated/shader_spirv.cpp )
target_sources( bgfx-shader-spirv INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/generated/shader_spirv.cpp )
target_include_directories( bgfx-shader-spirv INTERFACE ${BGFX_DIR}/include )

# Frameworks required on OS X
if( APPLE AND NOT IOS AND NOT VISIONOS)
	find_library( COCOA_LIBRARY Cocoa )
	mark_as_advanced( COCOA_LIBRARY )
	target_link_libraries( bgfx-vertexdecl INTERFACE ${COCOA_LIBRARY} )
endif()
