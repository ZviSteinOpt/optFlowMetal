#import "kernelUtils.h"

id<MTLDevice> device = MTLCreateSystemDefaultDevice();

void WeightedJacoby(id<MTLTexture> b ,id<MTLTexture> reg , id<MTLTexture> xNew, id<MTLTexture> xPrev, int itr_n)
{
    float omega = 2/3;
    id<MTLBuffer> factorBuffer = [device newBufferWithBytes:&omega
                                                    length:sizeof(float)
                                                   options:MTLResourceStorageModeShared];

    // Create command queue and buffer
    id<MTLCommandQueue> commandQueue = [device newCommandQueue];
    if (!commandQueue) throw std::runtime_error("Failed to create Metal command queue.");


    MTLSize threadGroupSize = MTLSizeMake(16, 16, 1);
    MTLSize threadGroups = MTLSizeMake((xNew.width + threadGroupSize.width - 1) / threadGroupSize.width,
                                       (xNew.height + threadGroupSize.height - 1) / threadGroupSize.height,1);

    NSString* functionName = @"weightedJacoby";
    
    auto pipelineState =  kernelCreator(device, commandQueue, functionName);
    
    
    for (int i = 0; i < itr_n; ++i) {

        auto [encoder, commandBuffer] = setKernel( commandQueue, pipelineState);

        [encoder setTexture:xNew atIndex:0];
        [encoder setTexture:b atIndex:1];
        [encoder setTexture:xPrev atIndex:2];
        [encoder setTexture:reg atIndex:3];
        [encoder setBuffer:factorBuffer offset:0 atIndex:4];

        executKernel(encoder , commandBuffer, threadGroups, threadGroupSize);

        std::swap(xNew, xPrev);

    }

}
