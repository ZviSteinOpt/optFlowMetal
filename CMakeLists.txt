cmake_minimum_required(VERSION 3.10)
project(MetalOpenCV)

# Specify C++ standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# OpenCV location (Homebrew)
set(OpenCV_DIR "/opt/homebrew/Cellar/opencv/4.10.0_19")
find_package(OpenCV REQUIRED)

# Ensure Metal & MPS are available
set(XCODE_SDK_PATH "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk")

if(NOT EXISTS "${XCODE_SDK_PATH}/System/Library/Frameworks/Metal.framework")
    message(FATAL_ERROR "Metal framework not found! Ensure Xcode is installed.")
endif()

if(NOT EXISTS "${XCODE_SDK_PATH}/System/Library/Frameworks/MetalPerformanceShaders.framework")
    message(FATAL_ERROR "Metal Performance Shaders framework not found! Ensure Xcode is installed.")
endif()

# Add subdirectories for both projects
add_subdirectory(src)
add_subdirectory(improc)

# Enable testing
enable_testing()

# Add the tests subdirectory
add_subdirectory(tests)