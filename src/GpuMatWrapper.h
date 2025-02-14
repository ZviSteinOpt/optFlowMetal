#ifndef GPUMATWRAPPER_H
#define GPUMATWRAPPER_H

#include <opencv2/opencv.hpp>
#include "GpuMat.h"

class GpuMatWrapper {
public:
    GpuMatWrapper();
    ~GpuMatWrapper();

    // Upload an OpenCV Mat to GPU
    void upload(const cv::Mat& mat);

    // Download data from GPU to OpenCV Mat
    void download(cv::Mat& mat);

    void create(int width, int height, int type);  // Create Metal texture with specified size and type

    GpuMat* data();
private:
    GpuMat* m_gpuMat;  // GpuMat instance for handling GPU operations
    
    int mapBGROpenCVToMetalPixelFormat(int type);
    int mapRGBOpenCVToMetalPixelFormat(int type);

};

#endif // GPUMATWRAPPER_H
