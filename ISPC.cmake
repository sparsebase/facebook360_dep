set(ISPC_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/source/thirdparty/bc7_compressor/ISPCTextureCompressor/ispc)
set(ISPC_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/ispc_build)
set(TEXCOMP_DIR ${ISPC_SOURCE_DIR}/ispc_texcomp)
set(ISPC_FLAGS -O2 -woff --arch=x86-64 --target=sse2,avx --opt=fast-math --pic)

if(APPLE)
  set(ISPC_EXEC "ispc_osx")
elseif(LINUX)
  set(ISPC_EXEC "ispc_linux")
elseif(WIN32)
  set(ISPC_EXEC "ispc.exe")
endif()

file(MAKE_DIRECTORY ${ISPC_BUILD_DIR})

add_custom_command(
  OUTPUT
    ${ISPC_BUILD_DIR}/kernel_astc_ispc.o
    ${ISPC_BUILD_DIR}/kernel_astc_ispc_sse2.o
    ${ISPC_BUILD_DIR}/kernel_astc_ispc_avx.o
    ${ISPC_BUILD_DIR}/kernel_astc_ispc.h
  COMMAND
    ${ISPC_SOURCE_DIR}/${ISPC_EXEC} ${ISPC_FLAGS} -o ${ISPC_BUILD_DIR}/kernel_astc_ispc.o
    -h ${ISPC_BUILD_DIR}/kernel_astc_ispc.h ${TEXCOMP_DIR}/kernel_astc.ispc
  DEPENDS
    ${TEXCOMP_DIR}/kernel_astc.ispc
)


add_custom_command(
  OUTPUT
    ${ISPC_BUILD_DIR}/kernel_ispc.o
    ${ISPC_BUILD_DIR}/kernel_ispc_sse2.o
    ${ISPC_BUILD_DIR}/kernel_ispc_avx.o
    ${ISPC_BUILD_DIR}/kernel_ispc.h
  COMMAND
    ${ISPC_SOURCE_DIR}/${ISPC_EXEC} ${ISPC_FLAGS} -o ${ISPC_BUILD_DIR}/kernel_ispc.o
    -h ${ISPC_BUILD_DIR}/kernel_ispc.h ${TEXCOMP_DIR}/kernel.ispc
  DEPENDS
    ${TEXCOMP_DIR}/kernel.ispc
)


add_library(
  ispc_pre OBJECT
  ${TEXCOMP_DIR}/ispc_texcomp.cpp
  ${TEXCOMP_DIR}/ispc_texcomp_astc.cpp
  ${ISPC_BUILD_DIR}/kernel_astc_ispc.h
  ${ISPC_BUILD_DIR}/kernel_ispc.h
)
target_include_directories(
  ispc_pre PRIVATE
  ${ISPC_BUILD_DIR}
)
set_target_properties(ispc_pre PROPERTIES COMPILE_FLAGS "-w")

add_library(
  ispc_texcomp 
  ${TEXCOMP_DIR}/ispc_texcomp.h
  $<TARGET_OBJECTS:ispc_pre>
  ${ISPC_BUILD_DIR}/kernel_astc_ispc.o
  ${ISPC_BUILD_DIR}/kernel_astc_ispc_sse2.o
  ${ISPC_BUILD_DIR}/kernel_astc_ispc_avx.o
  ${ISPC_BUILD_DIR}/kernel_ispc.o
  ${ISPC_BUILD_DIR}/kernel_ispc_sse2.o
  ${ISPC_BUILD_DIR}/kernel_ispc_avx.o
)
set_target_properties(ispc_texcomp PROPERTIES COMPILE_FLAGS "-w")
