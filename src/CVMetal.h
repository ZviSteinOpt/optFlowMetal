
#ifndef CVMETAL_H
#define CVMETAL_H

#include <cstddef> // For size_t
#import "GpuMat.h"

// Forward declaration of Metal types
typedef void* MTLDevice;
typedef void* MTLTexture;

class CVMetal {
    
public:
    CVMetal();
    ~CVMetal();

    void convert(GpuMat* rgbaImage, GpuMat* grayImage, float scale, float offset);
    void initializeDevice();
    void scale(GpuMat* image, float scaleFactor);
    void offset(GpuMat* image, float offsetFactor);

private:
    MTLDevice m_device;   // Forward-declared Metal device
};

#endif // OPTICALFLOW_H
