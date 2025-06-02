project(ImProc)

# Ensure OpenCV is found
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

# Define `ImProc` as a library, not an executable
add_library(ImProc SHARED
    ImageProc.mm
    ImageProc.h
    ImageProcWrapper.cpp
    ImageProcWrapper.h
)

# Make headers available to other targets
target_include_directories(ImProc PUBLIC
    ${CMAKE_SOURCE_DIR}/improc
)

# Link dependencies
target_link_libraries(ImProc
    ${OpenCV_LIBS}
    "-framework Metal"
    "-framework MetalPerformanceShaders"
    "-framework Foundation"
)