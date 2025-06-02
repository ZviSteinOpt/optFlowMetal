# Enable testing
enable_testing()

# Define MetalTests as a MODULE (not EXECUTABLE)
add_library(MetalTests MODULE
    srcTests.mm  # Objective-C++ XCTest wrapper
    srcTests.cpp # C++ test functions
)

# Ensure the test can include public headers from Src
target_include_directories(MetalTests PRIVATE
    ${CMAKE_SOURCE_DIR}/Src/include
    ${CMAKE_SOURCE_DIR}/tests  # Include the srcTests.h file
)

# Mark MetalTests as an XCTest bundle
set_target_properties(MetalTests PROPERTIES
    BUNDLE TRUE
    BUNDLE_EXTENSION "xctest"
    MACOSX_BUNDLE YES
    XCODE_PRODUCT_TYPE com.apple.product-type.bundle.unit-test
)

# Link MetalTests with XCTest, Metal, and Src
target_link_libraries(MetalTests
    PRIVATE Src
    ${OpenCV_LIBS}
    "-framework Metal"
    "-framework XCTest"
)

# Register the test in CMake
add_test(NAME SrcTests COMMAND MetalTests)