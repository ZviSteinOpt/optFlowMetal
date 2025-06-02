#ifndef GPUBUFFER_H
#define GPUBUFFER_H

#include <cstddef>   // for size_t
#import <simd/simd.h>
#import <Metal/Metal.h>
#include <vector>  // Ensure <vector> is included

// Opaque Objective‑C/Metal types for pure C++ header
typedef void* MTLDeviceHandle;
typedef void* MTLBufferHandle;


/// Lightweight wrapper for a Metal buffer.
/// Mirrors the style of GpuMat but for linear memory.
class GpuBuffer {
    
public:
    
    enum class Type {
        Unknown,
        Float,
        Float3,
        Float4,
        Int,
        Int3,
        Bool,
        Double
    };

    GpuBuffer();
    ~GpuBuffer();

    /// Allocates a GPU buffer of `sizeInBytes`. Previous buffer is released.
    void create(size_t size, Type dataType);

    /// Upload `sizeInBytes` bytes from CPU memory pointed by `data` to the GPU buffer.
    void upload(const void* data, size_t size, Type dataType);

    /// Download `sizeInBytes` bytes from the GPU buffer into CPU memory pointed by `dst`.
    template<typename T>
    void download(std::vector<T>& dst) {
        if (!m_buffer) return;
        size_t totalBytes = m_size * typeSize(m_type);
        dst.resize(totalBytes / sizeof(T));
        id<MTLBuffer> buffer = (id<MTLBuffer>)m_buffer;
        memcpy(dst.data(), [buffer contents], totalBytes);
    }

    /// Return raw Metal buffer handle (id<MTLBuffer> cast to void*).
    MTLBufferHandle data() const { return m_buffer; }

    /// Return the buffer size in bytes (0 if no buffer).
    size_t size() const;

private:
    void initializeDevice();
    size_t typeSize(Type type);
    
    MTLDeviceHandle  m_device {nullptr};   // Metal device
    MTLBufferHandle  m_buffer {nullptr};   // Metal buffer
    size_t           m_size   {0};         // cached size
    Type m_type     {Type::Unknown};

};

#endif // GPUBUFFER_H
