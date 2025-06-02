#import "kernelUtils.h"


std::pair<id<MTLComputeCommandEncoder>, id<MTLCommandBuffer>> setKernel(id<MTLCommandQueue> commandQueue, id<MTLComputePipelineState> pipelineState)
{
    // Create a command buffer and encoder
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    if (!commandBuffer) throw std::runtime_error("Failed to create command buffer.");

    id<MTLComputeCommandEncoder> encoder = [commandBuffer computeCommandEncoder];
    if (!encoder) throw std::runtime_error("Failed to create compute encoder.");

    // Set the compute pipeline state
    [encoder setComputePipelineState:pipelineState];

    return std::make_pair(encoder, commandBuffer);

}

id<MTLComputePipelineState> kernelCreator(id<MTLDevice> device,
                   id<MTLCommandQueue> commandQueue,
                   NSString* functionName) {
    NSError* error = nil;
    

    // Load and compile the Metal shader source
    NSString *shaderPath = [NSString stringWithFormat:@"/Users/zvistein/GitHub_repos/optFlowMetal/src/src/%@.metal", @"kernels"];

    NSString* metalSource = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!metalSource) throw std::runtime_error("Failed to load Metal source file.");

    id<MTLLibrary> library = [device newLibraryWithSource:metalSource options:nil error:&error];
    if (!library) throw std::runtime_error("Failed to compile Metal library.");

    // Load the kernel function
    id<MTLFunction> kernelFunction = [library newFunctionWithName:functionName];
    if (!kernelFunction) throw std::runtime_error("Failed to load kernel function.");

    // Create a compute pipeline state
    id<MTLComputePipelineState> pipelineState = [device newComputePipelineStateWithFunction:kernelFunction error:&error];
    if (!pipelineState) throw std::runtime_error("Failed to create pipeline state.");

    return pipelineState;

}

void executKernel(id<MTLComputeCommandEncoder> encoder , id<MTLCommandBuffer> commandBuffer, MTLSize threadGroups, MTLSize threadGroupSize)
{
    // Dispatch the compute command
    [encoder dispatchThreadgroups:threadGroups threadsPerThreadgroup:threadGroupSize];
    [encoder endEncoding];

    // Execute the command buffer
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];

}

//id<MTLDevice> device = MTLCreateSystemDefaultDevice();
