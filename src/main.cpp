#include <opencv2/opencv.hpp>
#include <opencv2/video/tracking.hpp>
#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/videoio.hpp>
#include <opencv2/video.hpp>
#include "GpuMatWrapper.h"
#include "CVMetal.h"

using namespace cv;
using namespace std;

int main() {
    GpuMatWrapper image;
    GpuMatWrapper imageGL;
    
    VideoCapture capture(samples::findFile("/Users/zvistein/Documents/CV/work chalanges/3D detection/camera2.mp4"));
    if (!capture.isOpened()){
        //error in opening the video input
        cerr << "Unable to open file!" << endl;
        return 0;
    }
    
    Mat frame1, prvs;
    capture >> frame1;
    cvtColor(frame1, prvs, COLOR_BGR2GRAY);
    
    cv::Mat alphaChannel(frame1.rows, frame1.cols, CV_8UC1, cv::Scalar(255));

    // Create an RGBA image by merging RGB and alpha channel
    cv::Mat rgbaImage;
    std::vector<cv::Mat> channels;
    cv::split(frame1, channels);         // Split RGB channels
    channels.push_back(alphaChannel);      // Add alpha channel
    cv::merge(channels, rgbaImage);        // Merge into RGBA image

    image.upload(rgbaImage);
    cv::Mat t(frame1.rows,frame1.cols, CV_32FC1);
    cv::Mat tt;
    image.download(tt);
    CVMetal().scale(image.data(),0.1);
    //cv::imshow("frame1", tt);
    //cv::waitKey(10);

    imageGL.upload(t);
    CVMetal().convert(image.data(),imageGL.data(),1.0,0.0);
    imageGL.download(t);
    std::cout << "t(50,50): " << t.at<float32_t>(4, 2) << std::endl;
    cv::imshow("frame1", t);
    cv::waitKey(10);

    // Print pixel value from tt (CV_8UC4, 4-channel unsigned 8-bit)
    cv::Vec4b pixelValue = tt.at<cv::Vec4b>(78, 50); // Vec4b is a vector of 4 unsigned 8-bit values
    std::cout << "tt(24,50): ["
              << (int)pixelValue[0] << ", "
              << (int)pixelValue[1] << ", "
              << (int)pixelValue[2] << ", "
              << (int)pixelValue[3] << "]" << std::endl;
    while(true){
        Mat frame2, next;
        capture >> frame2;
        if (frame2.empty())
            break;
        cvtColor(frame2, next, COLOR_BGR2GRAY);
        Mat flow(prvs.size(), CV_32FC2);
        calcOpticalFlowFarneback(prvs, next, flow, 0.5, 3, 15, 3, 5, 1.2, 0);
        // visualization
        Mat flow_parts[2];
        split(flow, flow_parts);
        Mat magnitude, angle, magn_norm;
        cartToPolar(flow_parts[0], flow_parts[1], magnitude, angle, true);
        normalize(magnitude, magn_norm, 0.0f, 1.0f, NORM_MINMAX);
        angle *= ((1.f / 360.f) * (180.f / 255.f));
        //build hsv image
        Mat _hsv[3], hsv, hsv8, bgr;
        _hsv[0] = angle;
        _hsv[1] = Mat::ones(angle.size(), CV_32F);
        _hsv[2] = magn_norm;
        merge(_hsv, 3, hsv);
        hsv.convertTo(hsv8, CV_8U, 255.0);
        cvtColor(hsv8, bgr, COLOR_HSV2BGR);
        imshow("frame2", bgr);
        int keyboard = waitKey(1);
        if (keyboard == 'q' || keyboard == 27)
            break;
        prvs = next;
        //cv::imshow("frame1", next);
        //cv::waitKey(0);
    }

    return 0;
}
