#ifndef GPUMAT_H
#define GPUMAT_H

#include <cstddef> // For size_t

// Use void* to avoid Objective-C dependencies in the header
typedef void* MTLDeviceHandle;
typedef void* MTLTextureHandle;

class GpuMat {
public:
    GpuMat();
    ~GpuMat();
    
    // Upload and download interface methods
    void create(int width, int height, int type);
    void upload(void* matData, int rows, int cols, int type, size_t step);
    void download(void* matData, size_t step);
    
    int rows() const { return m_height; }
    int cols() const { return m_width; }
    int type() const { return m_openCVType; }
    
    MTLTextureHandle data() const { return m_texture; }
    
private:
    MTLDeviceHandle m_device {nullptr};     // Metal device
    MTLTextureHandle m_texture {nullptr};   // Metal texture
    
    int m_width;  // Texture width
    int m_height; // Texture height
    int m_openCVType;
    
    // Private method to initialize the Metal device
    void initializeDevice();
};

#endif // GPUMAT_H
