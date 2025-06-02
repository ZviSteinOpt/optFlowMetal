#import "GpuBuffer.h"
#import <Metal/Metal.h>
#include <stdexcept> // For std::runtime_error

GpuBuffer::GpuBuffer() : m_device(nullptr), m_buffer(nullptr),m_size(0) {
    initializeDevice();
}

GpuBuffer::~GpuBuffer() {
    m_buffer = nullptr;
    m_device = nullptr;
}

void GpuBuffer::initializeDevice() {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (!device) {
        throw std::runtime_error("Metal is not supported on this device.");
    }
    m_device = static_cast<void*>(device); // Cast to void*
}

size_t GpuBuffer::typeSize(Type type) {
    switch (type) {
        case Type::Float:  return sizeof(float);
        case Type::Int:    return sizeof(int);
        case Type::Double: return sizeof(double);
        case Type::Bool:   return sizeof(bool);
        case Type::Float3: return sizeof(simd::float3);
        case Type::Float4: return sizeof(simd::float4);
        case Type::Int3:   return 3*sizeof(int);
        default: throw std::runtime_error("GpuBuffer::typeSize: Unknown type");
    }
}

void GpuBuffer::create(size_t size, Type dataType)
{
    m_type = dataType;
    m_size = size;
    size_t sizeInBytes = m_size*typeSize(m_type);
    m_buffer = [m_device newBufferWithLength:sizeInBytes options:MTLResourceStorageModeShared];

}


void GpuBuffer::upload(const void* data, size_t size, Type dataType)
{
    m_type = dataType;
    m_size = size;
    size_t sizeInBytes = m_size*typeSize(m_type);

    id<MTLBuffer> buffer = (id<MTLBuffer>)m_buffer;
    if (!buffer || sizeInBytes > [buffer length]) return;
    memcpy([buffer contents], data, sizeInBytes);
}

//template<typename T>
//void GpuBuffer::download(std::vector<T>& dst) {
//    if (!m_buffer) return;
//    size_t totalBytes = m_size * typeSize(m_type);
//    dst.resize(totalBytes / sizeof(T));
//    id<MTLBuffer> buffer = (id<MTLBuffer>)m_buffer;
//    memcpy(dst.data(), [buffer contents], totalBytes);
//}
