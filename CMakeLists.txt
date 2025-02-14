cmake_minimum_required(VERSION 3.10)
project(OpticalFlowProject)

# Specify the C++ standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# OpenCV location from Homebrew
set(OpenCV_DIR "/opt/homebrew/Cellar/opencv/4.10.0_19")

# Find OpenCV package
find_package(OpenCV REQUIRED)

# Include OpenCV headers
include_directories(${OpenCV_INCLUDE_DIRS})

# Check for Metal and MPS frameworks
if(NOT EXISTS "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Metal.framework")
    message(FATAL_ERROR "Metal framework not found!")
endif()

if(NOT EXISTS "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/MetalPerformanceShaders.framework")
    message(FATAL_ERROR "Metal Performance Shaders framework not found!")
endif()

# Include Metal and MPS headers only for .mm files
set(METAL_HEADERS
    "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Metal.framework/Headers"
    "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/MetalPerformanceShaders.framework/Headers"
)

set_source_files_properties(
    "${CMAKE_SOURCE_DIR}/src/CVMetal.mm"
    "${CMAKE_SOURCE_DIR}/src/GpuMat.mm"
    "/Users/zvistein/GitHub_repos/optFlowMetal/kernels.metal"
    PROPERTIES
    COMPILE_FLAGS "-I${METAL_HEADERS}"
)

# Add the executable with all source files
add_executable(OpticalFlowProject
    "${CMAKE_SOURCE_DIR}/src/main.cpp"
    "${CMAKE_SOURCE_DIR}/src/GpuMatWrapper.cpp"
    "${CMAKE_SOURCE_DIR}/src/GpuMatWrapper.h"
    "${CMAKE_SOURCE_DIR}/src/CVMetal.mm"
    "${CMAKE_SOURCE_DIR}/src/CVMetal.h"
    "${CMAKE_SOURCE_DIR}/src/GpuMat.h"
    "${CMAKE_SOURCE_DIR}/src/GpuMat.mm"
)

# Link OpenCV libraries
target_link_libraries(OpticalFlowProject ${OpenCV_LIBS})

# Link Metal and MPS frameworks
target_link_libraries(OpticalFlowProject
    "-framework Foundation"
    "-framework QuartzCore"
    "-framework Metal"
    "-framework MetalPerformanceShaders"
)