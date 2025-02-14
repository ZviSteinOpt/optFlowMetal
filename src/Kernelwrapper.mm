#import <Metal/Metal.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>
#import "optFlow.h"
#include <stdexcept> // For std::runtime_error
#include <vector>  // Ensure <vector> is included


// General kernel invocation function

void OpticalFlow::OpticalFlow() : m_device(nullptr) {
    initializeDevice();
}

OpticalFlow::~OpticalFlow() {}

void OpticalFlow::initializeDevice() {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (!device) {
        //throw std::runtime_error("Metal is not supported on this device.");
    }
    m_device = static_cast<void*>(device); // Cast to void*
}

void OpticalFlow::Subtract(MTLTexture image){
    id<MTLDevice> metalDevice = (__bridge id<MTLDevice>)m_device;
    id<MTLTexture> outputTexture = (__bridge id<MTLTexture>)image;

    // Create command queue and buffer
    id<MTLCommandQueue> commandQueue = [metalDevice newCommandQueue];
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];

    // Step 2: Create Intermediate Texture Descriptor
    MTLTextureDescriptor* intermediateDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:outputTexture.pixelFormat
                                                                                                      width:outputTexture.width
                                                                                                     height:outputTexture.height
                                                                                                  mipmapped:NO];
    intermediateDescriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite;

    id<MTLTexture> intermediateTexture = [metalDevice newTextureWithDescriptor:intermediateDescriptor];

    // Step 3: Subtract the Mean
    {
        
        // Create a constant texture for the mean
        MTLTextureDescriptor* meanDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:outputTexture.pixelFormat
                                                                                                   width:outputTexture.width
                                                                                                  height:outputTexture.height
                                                                                               mipmapped:NO];
        meanDescriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite;
        id<MTLTexture> meanTexture = [metalDevice newTextureWithDescriptor:meanDescriptor];

        // Fill the texture with the mean value
        float* meanData = (float*)malloc(sizeof(float) * outputTexture.width * outputTexture.height);
        for (NSUInteger i = 0; i < outputTexture.width * outputTexture.height; i++) {
            meanData[i] = m_mean; // m_mean should be set beforehand
        }

        [meanTexture replaceRegion:MTLRegionMake2D(0, 0, outputTexture.width, outputTexture.height)
                        mipmapLevel:0
                          withBytes:meanData
                        bytesPerRow:sizeof(float) * outputTexture.width];
        free(meanData);

        // Create a MPSImageSubtract filter
        MPSImageSubtract* subtractFilter = [[MPSImageSubtract alloc] initWithDevice:metalDevice];

        // Encode the subtraction operation
        [subtractFilter encodeToCommandBuffer:commandBuffer
                                primaryTexture:outputTexture
                              secondaryTexture:meanTexture
                             destinationTexture:intermediateTexture];

        [subtractFilter release];
        [meanTexture release];
        
        image = intermediateTexture;
    }

    // Commit and wait for execution
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];

}

std::pair<id<MTLComputeCommandEncoder>, id<MTLCommandBuffer>> kernelCreator(id<MTLDevice> device,
                   id<MTLCommandQueue> commandQueue,
                   NSString* functionName,
                   MTLSize gridSize,
                   MTLSize threadgroupSize,
                   std::vector<id<MTLTexture>> buffers) {
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


void OpticalFlow::a(GpuMat* rgbaImage, GpuMat* grayImage) {
    
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
    
    auto [encoder, commandBuffer] = kernelCreator(metalDevice, commandQueue, functionName, threadGroups, threadGroupSize, buffers);

    // Bind the buffers to the kernel
    for (size_t i = 0; i < buffers.size(); ++i) {
        [encoder setTexture:buffers[i] atIndex:i];
    }

    // Dispatch the compute command
    [encoder dispatchThreadgroups:gridSize threadsPerThreadgroup:threadgroupSize];
    [encoder endEncoding];

    // Execute the command buffer
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];

}

void OpticalFlow::Divide(GpuMat* image){
    
    id<MTLDevice> metalDevice = (__bridge id<MTLDevice>)m_device;
    id<MTLTexture> outputTexture = (__bridge id<MTLTexture>)image->data();

    // Create command queue and buffer
    id<MTLCommandQueue> commandQueue = [metalDevice newCommandQueue];
    if (!commandQueue) throw std::runtime_error("Failed to create Metal command queue.");

    std::vector<id<MTLTexture>> buffers = { outputTexture };

    MTLSize threadGroupSize = MTLSizeMake(16, 16, 1);
    MTLSize threadGroups = MTLSizeMake((outputTexture.width + threadGroupSize.width - 1) / threadGroupSize.width,
                                       (outputTexture.height + threadGroupSize.height - 1) / threadGroupSize.height,1);
    

    NSString* functionName = @"divide";
    
    // Invoke the kernel
    //invokeKernel(metalDevice, commandQueue, functionName, threadGroups, threadGroupSize, buffers);

}

void OpticalFlow::convertAndNormalize(GpuMat* rgbaImage, GpuMat* grayImage) {
    id<MTLDevice> metalDevice = (__bridge id<MTLDevice>)m_device;
    id<MTLTexture> inputTexture = (__bridge id<MTLTexture>)rgbaImage->data();
    id<MTLTexture> outputTexture = (__bridge id<MTLTexture>)grayImage->data();

    // Create command queue and buffer
    id<MTLCommandQueue> commandQueue = [metalDevice newCommandQueue];
    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];

    MPSAlphaType srcAlpha = MPSAlphaTypeNonPremultiplied; // Adjust if your input texture has premultiplied alpha
    MPSAlphaType destAlpha = MPSAlphaTypeNonPremultiplied;

    // Background color for alpha flattening (if needed)
    CGFloat backgroundColor[1] = {0}; // Single channel since we're converting to grayscale

    
    // No color space conversion (we'll use NULL for CGColorConversionInfoRef)
    CGColorConversionInfoRef conversionInfo = NULL;

    MPSImageConversion* conversion = [[MPSImageConversion alloc] initWithDevice:metalDevice
                                                                       srcAlpha:srcAlpha
                                                                      destAlpha:destAlpha
                                                                backgroundColor:backgroundColor
                                                                 conversionInfo:conversionInfo];

    [conversion encodeToCommandBuffer:commandBuffer
                        sourceTexture:inputTexture
                   destinationTexture:outputTexture];
    
    [conversion release];

    //Divide(outputTexture);
    //Subtract(outputTexture);

}
