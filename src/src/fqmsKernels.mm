#import "fqmsKernels.h"

id<MTLDevice> device = MTLCreateSystemDefaultDevice();

void countFaces(gpuVertices vertices, gpuFaces faces, gpuEdges edges,
                size_t numOfFaces, size_t numOfVertices)
{
    // Create Metal command queue
    id<MTLCommandQueue> commandQueue = [device newCommandQueue];
    if (!commandQueue)
        throw std::runtime_error("Failed to create Metal command queue.");

    // === Kernel launch configuration ===
    const NSUInteger threadsPerThreadgroup = 256;
    MTLSize threadGroupSize = MTLSizeMake(threadsPerThreadgroup, 1, 1);
    MTLSize threadGroups = MTLSizeMake(
        (numOfFaces + threadsPerThreadgroup - 1) / threadsPerThreadgroup,
        1,
        1
    );

    // === Compile and set up kernel ===
    NSString* functionName = @"countFaces";
    auto pipelineState = kernelCreator(device, commandQueue, functionName);
    auto [encoder, commandBuffer] = setKernel(commandQueue, pipelineState);

    // === Set kernel inputs ===
    [encoder setBuffer:faces.d_faces     offset:0 atIndex:0];
    [encoder setBuffer:faces.d_deleted   offset:0 atIndex:1];
    [encoder setBuffer:vertices.d_tcount offset:0 atIndex:2];

    // === Dispatch ===
    executKernel(encoder, commandBuffer, threadGroups, threadGroupSize);
}

