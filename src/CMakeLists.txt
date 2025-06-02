# Define the project
project(Src)

# Ensure C++ standard is set
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Find OpenCV
find_package(OpenCV REQUIRED)

# Define public headers (only these will be visible outside Src)
set(SRC_PUBLIC_HEADERS
    include/GpuMatWrapper.h
    include/CVMetal.h
    include/Solver.h
    include/GpuMat.h  # This is private
    include/fqms.h
    include/meshHandler.h
    include/GpuBuffer.h
    include/fqmsKernels.h
    include/kernelUtils.h

)

# Define source files (implementation files)
set(SRC_SOURCES
    src/GpuMatWrapper.cpp
    src/CVMetal.mm
    src/Solver.mm
    src/kernelUtils.mm
    src/SolverKernels.mm
    src/GpuMat.mm
    src/kernels.metal
    src/fqmsKernels.mm
    src/fqms.mm
    src/meshHandler.mm
    src/GpuBuffer.mm

)

# Define private headers (used internally within Src)
set(SRC_PRIVATE_HEADERS
      # This is private
)

# Create a library for Src
add_library(Src STATIC ${SRC_SOURCES} ${SRC_PUBLIC_HEADERS} ${SRC_PRIVATE_HEADERS})

# Expose only the public include directory to external projects
target_include_directories(Src PUBLIC
    ${CMAKE_SOURCE_DIR}/Src/include  # Only public headers are exposed
)

# Ensure private headers are visible to Src itself
target_include_directories(Src PRIVATE
    ${CMAKE_SOURCE_DIR}/Src/src  # Internal includes for private headers
)

# Link OpenCV
target_link_libraries(Src PRIVATE ${OpenCV_LIBS})

# Link Metal and MPS frameworks
target_link_libraries(Src PRIVATE
    "-framework Foundation"
    "-framework QuartzCore"
    "-framework Metal"
    "-framework MetalPerformanceShaders"
)

# Path to kernels.metal inside src/src
set(METAL_SRC_FILE ${CMAKE_CURRENT_SOURCE_DIR}/src/kernels.metal)

# Output path for compiled metallib
set(METAL_AIR_OUTPUT ${CMAKE_BINARY_DIR}/kernels.air)
set(METAL_LIB_OUTPUT ${CMAKE_BINARY_DIR}/kernels.metallib)

# Compile the .metal file into a .metallib
add_custom_command(
    OUTPUT ${METAL_LIB_OUTPUT}
    COMMAND xcrun -sdk macosx metal -c ${METAL_SRC_FILE} -o ${METAL_AIR_OUTPUT}
    COMMAND xcrun -sdk macosx metallib ${METAL_AIR_OUTPUT} -o ${METAL_LIB_OUTPUT}
    DEPENDS ${METAL_SRC_FILE}
    COMMENT "Compiling Metal shader: kernels.metal"
)

# Define a custom target for building the metallib
add_custom_target(metal_kernels DEPENDS ${METAL_LIB_OUTPUT})

# Make sure metallib gets built before Src
add_dependencies(Src metal_kernels)

# Ensure metallib is bundled into Resources of dependent targets (like .xctest)
set_source_files_properties(${METAL_LIB_OUTPUT} PROPERTIES
    MACOSX_PACKAGE_LOCATION Resources
)

# Include the metallib in the Src target
target_sources(Src PRIVATE ${METAL_LIB_OUTPUT})

# Ensure headers appear in Xcode under "Header Files"
source_group("Public Headers" FILES ${SRC_PUBLIC_HEADERS})
source_group("Private Headers" FILES ${SRC_PRIVATE_HEADERS})