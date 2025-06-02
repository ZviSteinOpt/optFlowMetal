#import <Metal/Metal.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>

#include <stdexcept> // For std::runtime_error
#include <vector>  // Ensure <vector> is included

std::pair<id<MTLComputeCommandEncoder>, id<MTLCommandBuffer>> setKernel(id<MTLCommandQueue> commandQueue, id<MTLComputePipelineState> pipelineState);


id<MTLComputePipelineState> kernelCreator(id<MTLDevice> device,
                   id<MTLCommandQueue> commandQueue,
                   NSString* functionName);

void executKernel(id<MTLComputeCommandEncoder> encoder , id<MTLCommandBuffer> commandBuffer, MTLSize threadGroups, MTLSize threadGroupSize);

