#ifndef FQMS_H
#define FQMS_H

#import "GpuBuffer.h"
#import "fqmsKernels.h"

// Forward declaration of Metal types
typedef void* MTLDevice;
typedef void* MTLTexture;


class fqms {
    
public:
    fqms();
    ~fqms();

    void uploadToGPU(const std::vector<simd::float3>& iVertices,const std::vector<uint32_t>& iIndices);
    
private:
    id<MTLDevice> m_device;   // Forward-declared Metal device
    
    void initializeDevice();
    void initVerticies();
    void initFaces();
    void initEdges();
        
    
    size_t numOfFaces;
    size_t numOfVertices;
    size_t numOfEdges;
    
    struct Vertices
    {
        // Vertex attributes
        GpuBuffer d_pos;    // float3* positions
        GpuBuffer d_q;      // float*  (10 floats per vertex)
        GpuBuffer d_tcount; // int*    triangle count
        GpuBuffer d_tstart; // int*    triangle start index
        GpuBuffer d_border; // uchar*  border flags
        
        gpuVertices data() {
            gpuVertices out;
            out.d_pos    = (id<MTLBuffer>)d_pos.data();
            out.d_q      = (id<MTLBuffer>)d_q.data();
            out.d_tcount = (id<MTLBuffer>)d_tcount.data();
            out.d_tstart = (id<MTLBuffer>)d_tstart.data();
            out.d_border = (id<MTLBuffer>)d_border.data();
            return out;
        }

    };
    
    struct Faces {
        GpuBuffer d_faces;   // int3*
        GpuBuffer d_error;   // float4*
        GpuBuffer d_deleted; // uchar*
        GpuBuffer d_dirty;   // uchar*
        GpuBuffer d_normals; // float3*

        gpuFaces data() {
            gpuFaces out;
            out.d_faces   = (id<MTLBuffer>)d_faces.data();
            out.d_error   = (id<MTLBuffer>)d_error.data();
            out.d_deleted = (id<MTLBuffer>)d_deleted.data();
            out.d_dirty   = (id<MTLBuffer>)d_dirty.data();
            out.d_normals = (id<MTLBuffer>)d_normals.data();
            return out;
        }
    };
    
    struct Edges {
        GpuBuffer d_tid;      // int*
        GpuBuffer d_tvertex;  // int*

        gpuEdges data() {
            gpuEdges out;
            out.d_tid     = (id<MTLBuffer>)d_tid.data();
            out.d_tvertex = (id<MTLBuffer>)d_tvertex.data();
            return out;
        }
    };
    
    
    Vertices vertices;
    Faces faces;
    Edges edges;
};

#endif // CVMETAL_H
