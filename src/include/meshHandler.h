// meshHandler.h
#ifndef MESH_HANDLER_H
#define MESH_HANDLER_H

#import <Metal/Metal.h>
#import <ModelIO/ModelIO.h>
#import <simd/simd.h>
#import <MetalKit/MetalKit.h>
#import <ModelIO/ModelIO.h>

#include <string>
#include <vector>

/// Simple container + I/O helper that owns CPU & GPU copies of a triangular mesh
class MeshHandler {
public:
    /// Construct with the Metal device you intend to upload to.
    explicit MeshHandler(id<MTLDevice> device);

    /// Load a *.ply* (ASCII or binary) mesh from disk. Returns *false* on I/O failure.
    bool readPLY(const std::string &path);

    /// Save the current mesh as *.ply*. Returns *false* if no mesh or write error.
    bool writePLY(const std::string &path) const;

    /// Upload current CPU-side arrays to GPU buffers. Safe to call multiple times after edits.
    /// No-op if mesh is empty.
    void uploadToGPU();

    /// Clear CPU arrays and release GPU resources.
    void clear();

    /// Accessors
    const std::vector<simd::float3>& vertices() const { return m_vertices; }
    const std::vector<uint32_t>&     indices () const { return m_indices;  }

private:
    // CPU-side containers
    std::vector<simd::float3> m_vertices;
    std::vector<uint32_t>     m_indices;

    id<MTLDevice> m_device = nil;

};

#endif // MESH_HANDLER_H
