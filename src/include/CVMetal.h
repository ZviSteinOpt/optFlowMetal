#ifndef CVMETAL_H
#define CVMETAL_H

#import "GpuMat.h"
#import "kernelUtils.h"

// Forward declaration of Metal types
typedef void* MTLDevice;
typedef void* MTLTexture;

class CVMetal {
    
public:
    CVMetal();
    ~CVMetal();

    static void convert(GpuMat* rgbaImage, GpuMat* grayImage, float scale, float offset);
    void initializeDevice();
    static void scale(GpuMat* image, float scaleFactor);
    static void offset(GpuMat* image, float offsetFactor);

private:
    MTLDevice m_device;   // Forward-declared Metal device    
};

#endif // OPTICALFLOW_H
