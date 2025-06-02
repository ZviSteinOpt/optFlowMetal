#import <XCTest/XCTest.h>
#import "srcTests.h"  // Include C++ test function declarations
#import "meshHandler.h"
#import "fqms.h"
#import <Metal/Metal.h>

@interface MetalProcessingTests : XCTestCase
@end

@implementation MetalProcessingTests

- (void)testMetalDevice {
    XCTAssertTrue(MetalTests::testMetalDevice(), "Metal device should be available!");
}

- (void)testMetalKernelExecution {
    XCTAssertTrue(MetalTests::testMetalKernelExecution(), "Metal kernel should execute successfully!");
}

- (void)testImageProcessing {
    XCTAssertTrue(MetalTests::testImageProcessing(), "Image processing should be successful!");
}

- (void)testReadMeshHandlerPLY {
    NSString *path = @"/Users/zvistein/GitHub_repos/optFlowMetal/tests/bunny/reconstruction/bun_zipper.ply";
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    XCTAssertNotNil(device, @"Metal device not created");

    MeshHandler handler(device);
    fqms fqmsIns;
    
    bool success = handler.readPLY([path UTF8String]);
    XCTAssertTrue(success, "Failed to read PLY mesh from file");

    NSLog(@"Read mesh: %lu vertices, %lu indices",
          handler.vertices().size(), handler.indices().size());

    fqmsIns.uploadToGPU(handler.vertices(),handler.indices());
//    XCTAssertNotNil(handler.vertexBuffer(), @"Vertex buffer upload failed");
//    XCTAssertNotNil(handler.indexBuffer(), @"Index buffer upload failed");
}

@end
