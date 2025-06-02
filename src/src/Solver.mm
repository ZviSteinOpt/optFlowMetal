#import <Metal/Metal.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>


#import "Solver.h"
#include <stdexcept> // For std::runtime_error
#include <vector>  // Ensure <vector> is included

Solver::Solver(int cols,int rows) : m_device(nullptr),mHight(rows),mWidth(cols) {
    initializeDevice();
}

Solver::~Solver() {}

void Solver::initializeDevice() {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (!device) {
        //throw std::runtime_error("Metal is not supported on this device.");
    }
    
    m_device = static_cast<void*>(device); // Cast to void*
}



void Solver::malocHendlar()
{

    for (int i = 0; i < 5; i++)
    {
        int factor = 1 << i;  // Use bit shift instead of ^ (bitwise XOR)
        GpuMat x;
        GpuMat x0;
        GpuMat b;
        GpuMat reg;
        x.create(mWidth / factor, mHight / factor, 5);
        x0.create(mWidth / factor, mHight / factor, 5);
        b.create(mWidth / factor, mHight / factor, 5);
        reg.create(mWidth / factor, mHight / factor, 5);
        mX.push_back(x);
        mX0.push_back(x0);
        mB.push_back(b);
        mReg.push_back(reg);
    }
    
}

void Solver::vCycle(int level)
{
    id<MTLTexture> b; id<MTLTexture> regj; id<MTLTexture> xNew; id<MTLTexture> xPrev; int itr_n;
    //WeightedJacoby( b, regj, xNew, xNew, itr_n);
    //WeightedJacoby( mB[level].data(), mReg[level].data(), mX[level].data(), mX0[level].data(), 20);
}
