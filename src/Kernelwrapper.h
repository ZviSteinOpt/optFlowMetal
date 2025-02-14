
#ifndef KERNELWRAPPER_H
#define KERNELWRAPPER_H

#include <cstddef> // For size_t
#import "GpuMat.h"

// Forward declaration of Metal types
typedef void* MTLDevice;
typedef void* MTLTexture;

class KernelWrapper {
public:
    KernelWrapper();
    ~KernelWrapper();

    void convertAndNormalize(GpuMat* rgbaImage, GpuMat* grayImage);
    void a(GpuMat* rgbaImage, GpuMat* grayImage);
    void initializeDevice();
    void Divide(GpuMat* image);
    void Subtract(MTLTexture image);

private:
    MTLDevice m_device;   // Forward-declared Metal device
    float m_mean = 0.0f;         // Mean value for normalization
    float m_stdDev = 1.0f;       // Standard deviation for normalization
};

#endif // OPTICALFLOW_H
