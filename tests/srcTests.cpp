#include <iostream>
#include <cassert>
#include <opencv2/opencv.hpp>
#include "GpuMatWrapper.h"
//#include "CVMetal.h"
#include <chrono>
#include <functional>  // For std::function

// Generic function to measure execution time
template <typename Func, typename... Args>
void measureTime(const std::string& functionName, Func&& func, Args&&... args) {
    auto start = std::chrono::high_resolution_clock::now();
    for(int i = 0;i<100;i++)
    {
        // Execute the function with the provided arguments
        std::forward<Func>(func)(std::forward<Args>(args)...);

    }

    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::milli> elapsedTime = (end - start)/100;

    std::cout << functionName << " execution time: " << elapsedTime.count() << " ms" << std::endl;
}

namespace MetalTests {

bool testMetalDevice() {
    /*
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (!device) {
        std::cerr << "[ERROR] Metal device is nil!" << std::endl;
        return false;
    }
    std::cout << "[TEST] Metal device is available!" << std::endl;
     */
    return true;
}

bool testMetalKernelExecution() {
    //bool success = GpuMatWrapper::testMetalKernel();
    bool success = true;
    if (!success) {
        std::cerr << "[ERROR] GpuMatWrapper::testMetalKernel() failed!" << std::endl;
    }
    return success;
}

bool testImageProcessing() {
    
//    cv::Mat frame1 = cv::imread("/Users/zvistein/Library/CloudStorage/OneDrive-post.bgu.ac.il/09 these/IMG_4517.jpg");
//
//    cv::Mat alphaChannel(frame1.rows, frame1.cols, CV_8UC1, cv::Scalar(255));
//    cv::Mat rgbaImage;
//    std::vector<cv::Mat> channels;
//    cv::split(frame1, channels);
//    channels.push_back(alphaChannel);
//    cv::merge(channels, rgbaImage);
//
//    GpuMatWrapper image;
//    GpuMatWrapper imageGL;
//    
//    int FLOPS_perCore_perCycle = 2;
//    int NumOfCores = 36;
//    double cycle = 1.296e9;
//    
//    image.upload(rgbaImage);
//    cv::Mat test1;
//    image.download(test1);
//    if (test1.empty()) {
//        std::cerr << "[ERROR] Downloaded image is empty!" << std::endl;
//        return false;
//    }
//    //cv::imshow("Test-upload/download",test1);
//    //cv::waitKey(10);
//
//    cv::Mat float1ChennelMAt(frame1.rows,frame1.cols, CV_32FC1);
//    imageGL.upload(float1ChennelMAt);
//
//    auto startScale = std::chrono::high_resolution_clock::now();
//    for(int i=0;i<100;i++)
//    {
//        //CVMetal::scale(image.data(),1.0);
//    }
//    auto endScale = std::chrono::high_resolution_clock::now();
//    std::chrono::duration<double, std::milli> scaleTime = (endScale - startScale)/100;
//    float runTimeMilli = 1000.0f*(image.rows()*image.cols()*3)/(FLOPS_perCore_perCycle*NumOfCores*cycle);
//    std::cout << "Scale function execution time: " << scaleTime.count() << " ms" << std::endl;
//    
//    if ((scaleTime.count()/runTimeMilli) > 1.1) {
//        std::cerr << "[ERROR] Run time higher than expected: "
//                  << runTimeMilli << "ms, Got: " << scaleTime.count() <<"ms"<< std::endl;
//    }
//
//    // Scale factor
//    double scaleFactor = 0.5;
//    cv::Mat scaledImage;
//
//    // Measure time
//    
//    //CVMetal::convert(image.data(),imageGL.data(),1.0,0.0);
//
//    imageGL.download(float1ChennelMAt);
//    
//    //cv::imshow("Test-GrayLevel", float1ChennelMAt);
//    //cv::waitKey(10);
//
//    // Print pixel value from tt (CV_8UC4, 4-channel unsigned 8-bit)
//    cv::Vec4b pixelValue = test1.at<cv::Vec4b>(50, 50);
//    float grayscaleValue = float1ChennelMAt.at<float>(50, 50);
//
//    // Compute expected grayscale value using equal weighting
//    int sumRGB = 0;
//    for (int i = 0; i < 3; i++) {
//        sumRGB += pixelValue[i];  // Sum of R, G, B
//    }
//
//    float fVal = float(sumRGB) / (255.0f * 3.0f);
//
//    // Allow a small margin for floating-point inaccuracies (epsilon)
//    const float epsilon = 1e-5f;
//    if (std::abs(fVal - grayscaleValue) > epsilon) {
//        std::cerr << "[ERROR] Grayscale conversion mismatch! Expected: "
//                  << fVal << ", Got: " << grayscaleValue << std::endl;
//        return false;
//    }

    return true;
}

} // namespace MetalTests
