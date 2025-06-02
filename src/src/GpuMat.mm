#import "GpuMat.h"
#import <Metal/Metal.h>
#include <stdexcept> // For std::runtime_error
MTLPixelFormat mapRGBOpenCVToMetalPixelFormat(int type);

GpuMat::GpuMat() : m_device(nullptr), m_texture(nullptr), m_width(0), m_height(0) {
    initializeDevice();
}

GpuMat::~GpuMat() {
    m_texture = nullptr;
    m_device = nullptr;
}

void GpuMat::initializeDevice() {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (!device) {
        throw std::runtime_error("Metal is not supported on this device.");
    }
    m_device = static_cast<void*>(device); // Cast to void*
}

void GpuMat::upload(void* matData, int rows, int cols, int type, size_t step) {
    
    if (!m_device) {
        throw std::runtime_error("Metal device is not initialized.");
    }

    id<MTLDevice> device = static_cast<id<MTLDevice>>(m_device); // Cast back to id<MTLDevice>

    NSUInteger width = static_cast<NSUInteger>(cols);
    NSUInteger height = static_cast<NSUInteger>(rows);
    m_openCVType = type;
    
    // Create a texture descriptor
    MTLTextureDescriptor* descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:mapRGBOpenCVToMetalPixelFormat(type)
                                                                                          width:width
                                                                                         height:height
                                                                                      mipmapped:NO];
    descriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite;

    // Create Metal texture
    id<MTLTexture> texture = [device newTextureWithDescriptor:descriptor];
    if (!texture) {
        throw std::runtime_error("Failed to create Metal texture.");
    }
    m_texture = static_cast<void*>(texture); // Cast to void*

    // Copy matData into the texture
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    
    //NSLog(@"Uploading texture...");
    //NSLog(@"Input dimensions: width=%lu, height=%lu", (unsigned long)width, (unsigned long)height);
    //NSLog(@"Bytes per row (step): %lu", (unsigned long)step);
    //NSLog(@"Texture pointer: %@", m_texture);

    // Check if data is valid
    if (!matData) {
        NSLog(@"Error: matData is null");
        throw std::runtime_error("Input data pointer (matData) is null.");
    }

    // Debug Metal texture state
    if (!m_texture) {
        NSLog(@"Error: Texture not initialized");
        throw std::runtime_error("Texture is not initialized.");
    }
    
    [texture replaceRegion:region
                mipmapLevel:0
                  withBytes:matData
                bytesPerRow:step];

    m_width = cols;
    m_height = rows;
}

void GpuMat::download(void* matData,size_t step) {
    
    if (!m_texture) {
        throw std::runtime_error("Texture is not initialized.");
    }

    id<MTLTexture> texture = static_cast<id<MTLTexture>>(m_texture); // Cast back to id<MTLTexture>

    // Copy texture data back to matData
    MTLRegion region = MTLRegionMake2D(0, 0, m_width, m_height);
    [texture getBytes:matData
           bytesPerRow:step
            fromRegion:region
           mipmapLevel:0];
}

void GpuMat::create(int width, int height, int type) {
    
    m_width = width;
    
    m_height = height;


    // Create texture descriptor
    MTLTextureDescriptor* descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:mapRGBOpenCVToMetalPixelFormat(type)
                                                                                          width:width
                                                                                         height:height
                                                                                      mipmapped:NO];
    descriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite;
    descriptor.storageMode = MTLStorageModePrivate;

    // Allocate Metal texture
    m_texture = [m_device newTextureWithDescriptor:descriptor];

    if (!m_texture) {
        throw std::runtime_error("Failed to create Metal texture.");
    }
}

MTLPixelFormat mapRGBOpenCVToMetalPixelFormat(int type) {
    switch (type) {
        case 0:  // 8-bit single-channel grayscale
            return MTLPixelFormatR8Unorm;

        case 8:  // 8-bit 2-channel (RG)
            return MTLPixelFormatRG8Unorm;

        case 16:  // 8-bit 3-channel (RGB)
            return MTLPixelFormatRGBA8Unorm;  // Metal does not support RGB directly

        case 24:  // 8-bit 4-channel (RGBA)
            return MTLPixelFormatRGBA8Unorm;

        case 2:  // 16-bit single-channel grayscale
            return MTLPixelFormatR16Unorm;

        case 10:  // 16-bit 2-channel (RG)
            return MTLPixelFormatRG16Unorm;

        case 18:  // 16-bit 3-channel (RGB)
            return MTLPixelFormatRGBA16Unorm;  // No direct RGB16 format

        case 26:  // 16-bit 4-channel (RGBA)
            return MTLPixelFormatRGBA16Unorm;

        case 5:  // 32-bit floating-point single-channel (grayscale)
            return MTLPixelFormatR32Float;

        case 13:  // 32-bit floating-point 2-channel (RG)
            return MTLPixelFormatRG32Float;

        case 21:  // 32-bit floating-point 3-channel (RGB)
            return MTLPixelFormatRGBA32Float;  // No direct RGB32F format

        case 29:  // 32-bit floating-point 4-channel (RGBA)
            return MTLPixelFormatRGBA32Float;

        default:
            throw std::invalid_argument("Unsupported OpenCV type for Metal texture.");
    }
}

MTLPixelFormat mapOpenCVBGRToMetalPixelFormat(int type) {
    switch (type) {
        case 0:  // 8-bit single-channel grayscale
            return MTLPixelFormatR8Unorm;

        case 8:  // 8-bit 2-channel (GB)
            return MTLPixelFormatRG8Unorm;

        case 16:  // 8-bit 3-channel (BGR)
            return MTLPixelFormatBGRA8Unorm;  // Use BGRA format in Metal

        case 24:  // 8-bit 4-channel (BGRA)
            return MTLPixelFormatBGRA8Unorm;

        case 2:  // 16-bit single-channel grayscale
            return MTLPixelFormatR16Unorm;

        case 10:  // 16-bit 2-channel (GB)
            return MTLPixelFormatRG16Unorm;

        case 18:  // 16-bit 3-channel (BGR)
            return MTLPixelFormatRGBA16Unorm;  // No direct BGR16 format, using RGBA16

        case 26:  // 16-bit 4-channel (BGRA)
            return MTLPixelFormatRGBA16Unorm;

        case 5:  // 32-bit floating-point single-channel (grayscale)
            return MTLPixelFormatR32Float;

        case 13:  // 32-bit floating-point 2-channel (GB)
            return MTLPixelFormatRG32Float;

        case 21:  // 32-bit floating-point 3-channel (BGR)
            return MTLPixelFormatRGBA32Float;  // No direct BGR32F format, using RGBA32F

        case 29:  // 32-bit floating-point 4-channel (BGRA)
            return MTLPixelFormatRGBA32Float;

        default:
            throw std::invalid_argument("Unsupported OpenCV BGR type for Metal texture.");
    }
}
