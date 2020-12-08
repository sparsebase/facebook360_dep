CMAKE_MINIMUM_REQUIRED(VERSION 3.2)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()
set(CMAKE_CONFIGURATION_TYPES ${CMAKE_BUILD_TYPE} CACHE STRING "" FORCE)

find_package(Boost REQUIRED)
find_package(Eigen3 CONFIG REQUIRED)
find_package(glog CONFIG REQUIRED)
find_package(OPENGL)
find_package(Folly CONFIG REQUIRED)
find_package(double-conversion CONFIG REQUIRED)
find_package(GLEW REQUIRED)
find_package(GLFW3 REQUIRED)
find_package(ZLIB REQUIRED)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

# OCULUS_ROOT and AUDIO360_ROOT must be defined in the windows as environment variables
if(NOT DEFINED OCULUS_ROOT)
  set(OCULUS_ROOT $ENV{OCULUS_ROOT})
  string(REPLACE "\\" "/" OCULUS_ROOT ${OCULUS_ROOT})
endif(NOT DEFINED OCULUS_ROOT)

if(NOT DEFINED AUDIO360_ROOT)
  set(AUDIO360_ROOT $ENV{AUDIO360_ROOT})
  string(REPLACE "\\" "/" AUDIO360_ROOT ${AUDIO360_ROOT})
endif(NOT DEFINED AUDIO360_ROOT)

include_directories(${OCULUS_ROOT})
include_directories(${OCULUS_ROOT}/LibOVR/Include)
include_directories(${OCULUS_ROOT}/LibOVRKernel/Src)
include_directories(${AUDIO360_ROOT}/include)
include_directories(${GLFW_ROOT}/include)
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/..")

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

### TARGET RiftViewer ###

add_executable(
  RiftViewer
  ../source/viewer/RiftViewer.cpp
  ../source/util/Camera.cpp
  ../source/util/SystemUtil.cpp
  ../source/render/RigScene.cpp
  ${OCULUS_ROOT}/LibOVRKernel/Src/GL/CAPI_GLE.cpp
)

target_link_libraries(
  RiftViewer
  glog::glog
  Folly::folly
  Eigen3::Eigen
  double-conversion::double-conversion
  ${AUDIO360_ROOT}/Windows/x64/Audio360.lib
  ${OCULUS_ROOT}/LibOVR/Lib/Windows/x64/Release/VS2017/LibOVR.lib
  ${OPENGL_LIBRARIES}
)

target_compile_definitions(
  RiftViewer
  PRIVATE FB360_DEP_USE_OVR_CAPI_GLE=1
)

# The following has already been build by the main cmake file
#add_executable(
#  OpenGLViewer
#  ../source/viewer/GlViewer.cpp
#  ../source/util/Camera.cpp
#  ../source/util/SystemUtil.cpp
#  ../source/render/RigScene.cpp
#  ../source/gpu/GlfwUtil.cpp
#)

#target_link_libraries(
#  OpenGLViewer
#  glog::glog
#  Folly::folly
#  Eigen3::Eigen
#  double-conversion::double-conversion
#  ${OPENGL_LIBRARIES}
#  ${GLFW_ROOT}/build/src/${CMAKE_BUILD_TYPE}/glfw3.lib
#  GLEW::GLEW
#)
