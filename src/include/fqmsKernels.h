#import "kernelUtils.h"


struct gpuVertices
{
    // Vertex attributes
    id<MTLBuffer> d_pos;    // float3* positions
    id<MTLBuffer> d_q;      // float*  (10 floats per vertex)
    id<MTLBuffer> d_tcount; // int*    triangle count
    id<MTLBuffer> d_tstart; // int*    triangle start index
    id<MTLBuffer> d_border; // uchar*  border flags
};

struct gpuFaces
{
    // Face attributes
    id<MTLBuffer> d_faces;   // int3*   vertex indices
    id<MTLBuffer> d_error;   // float4* error values
    id<MTLBuffer> d_deleted; // uchar*  face deleted flag
    id<MTLBuffer> d_dirty;   // uchar*  dirty flag
    id<MTLBuffer> d_normals; // float3* face normals
};

struct gpuEdges
{
    // Edge attributes
    id<MTLBuffer> d_tid;      // int* triangle id per edge
    id<MTLBuffer> d_tvertex; // int* vertex id per triangle/edge
};


void countFaces(gpuVertices vertices ,gpuFaces faces, gpuEdges edges, size_t numOfFaces, size_t numOfvertices);


