#import "CVMetal.h"

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


id<MTLDevice> device = MTLCreateSystemDefaultDevice();

void CVMetal::offset(GpuMat* image, float Factor){
    id<MTLDevice> metalDevice = (__bridge id<MTLDevice>)device;
    id<MTLTexture> outputTexture = (__bridge id<MTLTexture>)image->data();
    id<MTLBuffer> factorBuffer = [device newBufferWithBytes:&Factor
                                                    length:sizeof(float)
                                                   options:MTLResourceStorageModeShared];

    // Create command queue and buffer
    id<MTLCommandQueue> commandQueue = [metalDevice newCommandQueue];
    if (!commandQueue) throw std::runtime_error("Failed to create Metal command queue.");


    MTLSize threadGroupSize = MTLSizeMake(16, 16, 1);
    MTLSize threadGroups = MTLSizeMake((outputTexture.width + threadGroupSize.width - 1) / threadGroupSize.width,
                                       (outputTexture.height + threadGroupSize.height - 1) / threadGroupSize.height,1);
    

    NSString* functionName = @"offset";
    
    auto pipelineState =  kernelCreator(metalDevice, commandQueue, functionName);
    auto [encoder, commandBuffer] = setKernel( commandQueue, pipelineState);
    
    [encoder setTexture:outputTexture atIndex:0];
    [encoder setBuffer:factorBuffer offset:0 atIndex:1];
    
    executKernel(encoder , commandBuffer, threadGroups, threadGroupSize);
}

void CVMetal::convert(GpuMat* rgbaImage, GpuMat* grayImage, float scale, float offset) {
    
    id<MTLBuffer> scaleBuffer = [device newBufferWithBytes:&scale
                                                    length:sizeof(float)
                                                   options:MTLResourceStorageModeShared];
    id<MTLBuffer> offsetBuffer = [device newBufferWithBytes:&offset
                                                    length:sizeof(float)
                                                   options:MTLResourceStorageModeShared];

    id<MTLDevice> metalDevice = (__bridge id<MTLDevice>)device;
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
    auto pipelineState =  kernelCreator(metalDevice, commandQueue, functionName);
    auto [encoder, commandBuffer] = setKernel( commandQueue, pipelineState);

    [encoder setTexture:inputTexture atIndex:0];
    [encoder setTexture:outputTexture atIndex:1];
    [encoder setBuffer:scaleBuffer offset:0 atIndex:2];
    [encoder setBuffer:offsetBuffer offset:0 atIndex:3];

    executKernel(encoder , commandBuffer, threadGroups, threadGroupSize);

}

void CVMetal::scale(GpuMat* image, float factor){
    
    id<MTLDevice> metalDevice = (__bridge id<MTLDevice>)device;
    id<MTLTexture> outputTexture = (__bridge id<MTLTexture>)image->data();
    id<MTLBuffer> factorBuffer = [device newBufferWithBytes:&factor
                                                    length:sizeof(float)
                                                   options:MTLResourceStorageModeShared];

    // Create command queue and buffer
    id<MTLCommandQueue> commandQueue = [metalDevice newCommandQueue];
    if (!commandQueue) throw std::runtime_error("Failed to create Metal command queue.");


    MTLSize threadGroupSize = MTLSizeMake(16, 16, 1);
    MTLSize threadGroups = MTLSizeMake((outputTexture.width + threadGroupSize.width - 1) / threadGroupSize.width,
                                       (outputTexture.height + threadGroupSize.height - 1) / threadGroupSize.height,1);
    

    NSString* functionName = @"scale";
    
    auto pipelineState =  kernelCreator(metalDevice, commandQueue, functionName);
    auto [encoder, commandBuffer] = setKernel( commandQueue, pipelineState);

    [encoder setTexture:outputTexture atIndex:0];
    [encoder setBuffer:factorBuffer offset:0 atIndex:1];
    
    executKernel(encoder , commandBuffer, threadGroups, threadGroupSize);

}

