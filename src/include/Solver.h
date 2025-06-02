#ifndef CVMETAL_H
#define CVMETAL_H

#import "GpuMat.h"
#include <vector>

// Forward declaration of Metal types
typedef void* MTLDevice;
typedef void* MTLTexture;

class Solver {
    
public:
    Solver(int cols,int rows);
    ~Solver();

    void malocHendlar();

private:
    MTLDevice m_device;   // Forward-declared Metal device
    std::vector<GpuMat> mB;
    std::vector<GpuMat> mX;
    std::vector<GpuMat> mX0;
    std::vector<GpuMat> mReg;
    
    void initializeDevice();
    void vCycle(int level);

    int mWidth;
    int mHight;
};

#endif // OPTICALFLOW_H
