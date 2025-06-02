#import "GpuMatWrapper.h"

GpuMatWrapper::GpuMatWrapper() {
    m_gpuMat = new GpuMat();
}

GpuMatWrapper::~GpuMatWrapper() {
    delete m_gpuMat;
    m_gpuMat = nullptr;  // Optional but helps to avoid dangling pointers
}


void GpuMatWrapper::upload(const cv::Mat& mat) {
    
    if (mat.empty()) {
        throw std::runtime_error("Input cv::Mat is empty.");
    }

    // Upload cv::Mat data to GPU
    m_gpuMat->upload(mat.data, mat.rows, mat.cols, mat.type(), mat.step);
}

void GpuMatWrapper::download(cv::Mat& mat) {
    
    mat.create(m_gpuMat->rows(), m_gpuMat->cols(), m_gpuMat->type());
    
    // Download data from GPU to cv::Mat
    m_gpuMat->download(mat.data, mat.step);
}

int GpuMatWrapper::mapRGBOpenCVToMetalPixelFormat(int type) {
    switch (type) {
        case CV_8UC1:  // 8-bit single-channel grayscale
            return 10;  // MTLPixelFormatR8Unorm

        case CV_8UC2:  // 8-bit 2-channel (e.g., RG)
            return 30;  // MTLPixelFormatRG8Unorm

        case CV_8UC3:  // 8-bit 3-channel (RGB)
            return 70;  // MTLPixelFormatRGBA8Unorm (Use RGB format)

        case CV_8UC4:  // 8-bit 4-channel (RGBA)
            return 70;  // MTLPixelFormatRGBA8Unorm

        case CV_16UC1:  // 16-bit single-channel grayscale
            return 20;  // MTLPixelFormatR16Unorm

        case CV_16UC2:  // 16-bit 2-channel (RG)
            return 60;  // MTLPixelFormatRG16Unorm

        case CV_16UC3:  // 16-bit 3-channel (RGB)
            return 110;  // MTLPixelFormatRGBA16Unorm

        case CV_16UC4:  // 16-bit 4-channel (RGBA)
            return 110;  // MTLPixelFormatRGBA16Unorm

        case CV_32FC1:  // 32-bit floating-point single-channel (grayscale)
            return 55;  // MTLPixelFormatR32Float

        case CV_32FC2:  // 32-bit floating-point 2-channel (RG)
            return 105;  // MTLPixelFormatRG32Float

        case CV_32FC3:  // 32-bit floating-point 3-channel (RGB)
            return 125;  // MTLPixelFormatRGBA32Float

        case CV_32FC4:  // 32-bit floating-point 4-channel (RGBA)
            return 125;  // MTLPixelFormatRGBA32Float

        default:
            throw std::invalid_argument("Unsupported OpenCV type for Metal texture.");
    }
}

int GpuMatWrapper::mapBGROpenCVToMetalPixelFormat(int type) {
    switch (type) {
        case CV_8UC1:  // 8-bit single-channel grayscale
            return 10;  // MTLPixelFormatR8Unorm

        case CV_8UC2:  // 8-bit 2-channel (e.g., RG)
            return 30;  // MTLPixelFormatRG8Unorm

        case CV_8UC3:  // 8-bit 3-channel (BGR)
            return 80;  // MTLPixelFormatBGRA8Unorm (BGR closest to BGRA)

        case CV_8UC4:  // 8-bit 4-channel (BGRA)
            return 80;  // MTLPixelFormatBGRA8Unorm

        case CV_16UC1:  // 16-bit single-channel grayscale
            return 20;  // MTLPixelFormatR16Unorm

        case CV_16UC2:  // 16-bit 2-channel (RG)
            return 60;  // MTLPixelFormatRG16Unorm

        case CV_16UC3:  // 16-bit 3-channel (BGR)
            return 110;  // MTLPixelFormatRGBA16Unorm (no direct BGR16 format)

        case CV_16UC4:  // 16-bit 4-channel (BGRA)
            return 110;  // MTLPixelFormatRGBA16Unorm

        case CV_32FC1:  // 32-bit floating-point single-channel (grayscale)
            return 55;  // MTLPixelFormatR32Float

        case CV_32FC2:  // 32-bit floating-point 2-channel (RG)
            return 105;  // MTLPixelFormatRG32Float

        case CV_32FC3:  // 32-bit floating-point 3-channel (BGR)
            return 125;  // MTLPixelFormatRGBA32Float (no direct BGR32F format)

        case CV_32FC4:  // 32-bit floating-point 4-channel (BGRA)
            return 125;  // MTLPixelFormatRGBA32Float

        default:
            throw std::invalid_argument("Unsupported OpenCV type for Metal texture.");
    }
}

void GpuMatWrapper::create(int width, int height, int type) {
    
    if (!m_gpuMat) {
        m_gpuMat = new GpuMat();  // Ensure GpuMat is initialized
    }

    // Call GpuMat's create method to initialize the texture
    m_gpuMat->create(width, height, type);
}

GpuMat* GpuMatWrapper::data(){
    return m_gpuMat;
}
