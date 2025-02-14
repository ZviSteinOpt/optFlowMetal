#import <Metal/Metal.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>
#import "CVMetal.h"
#include <stdexcept> // For std::runtime_error
#include <vector>  // Ensure <vector> is included

CVMetal::CVMetal() : m_device(nullptr) {
    initializeDevice();
}

CVMetal::~CVMetal() {}

void CVMetal::initializeDevice() {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (!device) {
        //throw std::runtime_error("Metal is not supported on this device.");
    }
    m_device = static_cast<void*>(device); // Cast to void*
}


std::pair<id<MTLComputeCommandEncoder>, id<MTLCommandBuffer>> kernelCreator(id<MTLDevice> device,
                   id<MTLCommandQueue> commandQueue,
                   NSString* functionName) {
    NSError* error = nil;

    // Load and compile the Metal shader source
    NSString *shaderPath = [NSString stringWithFormat:@"/Users/zvistein/GitHub_repos/optFlowMetal/%@.metal", @"kernels"];

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

    // Create a command buffer and encoder
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    if (!commandBuffer) throw std::runtime_error("Failed to create command buffer.");

    id<MTLComputeCommandEncoder> encoder = [commandBuffer computeCommandEncoder];
    if (!encoder) throw std::runtime_error("Failed to create compute encoder.");

    // Set the compute pipeline state
    [encoder setComputePipelineState:pipelineState];

    return std::make_pair(encoder, commandBuffer);

    
}

void CVMetal::offset(GpuMat* image, float Factor){
    id<MTLDevice> metalDevice = (__bridge id<MTLDevice>)m_device;
    id<MTLTexture> outputTexture = (__bridge id<MTLTexture>)image->data();
    id<MTLBuffer> factorBuffer = [m_device newBufferWithBytes:&Factor
                                                    length:sizeof(float)
                                                   options:MTLResourceStorageModeShared];

    // Create command queue and buffer
    id<MTLCommandQueue> commandQueue = [metalDevice newCommandQueue];
    if (!commandQueue) throw std::runtime_error("Failed to create Metal command queue.");


    MTLSize threadGroupSize = MTLSizeMake(16, 16, 1);
    MTLSize threadGroups = MTLSizeMake((outputTexture.width + threadGroupSize.width - 1) / threadGroupSize.width,
                                       (outputTexture.height + threadGroupSize.height - 1) / threadGroupSize.height,1);
    

    NSString* functionName = @"offset";
    
    auto [encoder, commandBuffer] = kernelCreator(metalDevice, commandQueue, functionName);

    [encoder setTexture:outputTexture atIndex:0];
    [encoder setBuffer:factorBuffer offset:0 atIndex:1];
    
    // Dispatch the compute command
    [encoder dispatchThreadgroups:threadGroups threadsPerThreadgroup:threadGroupSize];
    [encoder endEncoding];

    // Execute the command buffer
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];

}

void CVMetal::convert(GpuMat* rgbaImage, GpuMat* grayImage, float scale, float offset) {
    id<MTLBuffer> scaleBuffer = [m_device newBufferWithBytes:&scale
                                                    length:sizeof(float)
                                                   options:MTLResourceStorageModeShared];
    id<MTLBuffer> offsetBuffer = [m_device newBufferWithBytes:&offset
                                                    length:sizeof(float)
                                                   options:MTLResourceStorageModeShared];

    id<MTLDevice> metalDevice = (__bridge id<MTLDevice>)m_device;
    id<MTLTexture> inputTexture = (__bridge id<MTLTexture>)rgbaImage->data();
    id<MTLTexture> outputTexture = (__bridge id<MTLTexture>)grayImage->data();
    
    std::vector<id<MTLTexture>> buffers = { inputTexture, outputTexture };

    MTLSize threadGroupSize = MTLSizeMake(16, 16, 1);
    MTLSize threadGroups = MTLSizeMake((inputTexture.width + threadGroupSize.width - 1) / threadGroupSize.width,
                                       (inputTexture.height + threadGroupSize.height - 1) / threadGroupSize.height,
                                       1);
    id<MTLCommandQueue> commandQueue;
    // Create a new Metal command queue
    commandQueue = [metalDevice newCommandQueue];
    if (!commandQueue) throw std::runtime_error("Failed to create Metal command queue.");

    NSString* functionName = @"rgbToGrayscale";
    
    // Create the kernel
    auto [encoder, commandBuffer] = kernelCreator(metalDevice, commandQueue, functionName);

    [encoder setTexture:inputTexture atIndex:0];
    [encoder setTexture:outputTexture atIndex:1];
    [encoder setBuffer:scaleBuffer offset:0 atIndex:2];
    [encoder setBuffer:offsetBuffer offset:0 atIndex:3];

    // Dispatch the compute command
    [encoder dispatchThreadgroups:threadGroups threadsPerThreadgroup:threadGroupSize];
    [encoder endEncoding];

    // Execute the command buffer
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];

}

void CVMetal::scale(GpuMat* image, float factor){
    
    id<MTLDevice> metalDevice = (__bridge id<MTLDevice>)m_device;
    id<MTLTexture> outputTexture = (__bridge id<MTLTexture>)image->data();
    id<MTLBuffer> factorBuffer = [m_device newBufferWithBytes:&factor
                                                    length:sizeof(float)
                                                   options:MTLResourceStorageModeShared];

    // Create command queue and buffer
    id<MTLCommandQueue> commandQueue = [metalDevice newCommandQueue];
    if (!commandQueue) throw std::runtime_error("Failed to create Metal command queue.");


    MTLSize threadGroupSize = MTLSizeMake(16, 16, 1);
    MTLSize threadGroups = MTLSizeMake((outputTexture.width + threadGroupSize.width - 1) / threadGroupSize.width,
                                       (outputTexture.height + threadGroupSize.height - 1) / threadGroupSize.height,1);
    

    NSString* functionName = @"scale";
    
    auto [encoder, commandBuffer] = kernelCreator(metalDevice, commandQueue, functionName);

    [encoder setTexture:outputTexture atIndex:0];
    [encoder setBuffer:factorBuffer offset:0 atIndex:1];
    
    // Dispatch the compute command
    [encoder dispatchThreadgroups:threadGroups threadsPerThreadgroup:threadGroupSize];
    [encoder endEncoding];

    // Execute the command buffer
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
}
