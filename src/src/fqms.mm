#import "fqms.h"

fqms::fqms() {
    initializeDevice();
}

fqms::~fqms() {}

void fqms::initializeDevice() {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (!device) {
        //throw std::runtime_error("Metal is not supported on this device.");
    }
    
    m_device = device;
}

void fqms::uploadToGPU(const std::vector<simd::float3>& iVertices,const std::vector<uint32_t>& iIndices)
{
    if (iVertices.empty() || iIndices.empty()) return;
    
    numOfFaces = iIndices.size() / 3;
    numOfVertices = iVertices.size();
    numOfEdges = numOfFaces * 3;
    
    vertices.d_pos.upload(iVertices.data(), iVertices.size(), GpuBuffer::Type::Float3);
    faces.d_faces.upload(iIndices.data(), iIndices.size(), GpuBuffer::Type::Int3);
    
    initVerticies();
    initFaces();
    initEdges();
    
    countFaces(vertices.data(),faces.data(),edges.data(),numOfFaces,numOfVertices);
    std::vector<float> cpuData;
    vertices.d_pos.download(cpuData);
}

void fqms::initVerticies()
{
    vertices.d_q.create(numOfVertices, GpuBuffer::Type::Float);      // float*  (10 floats per vertex)
    vertices.d_tcount.create(numOfVertices, GpuBuffer::Type::Int); // int*    triangle count
    vertices.d_tstart.create(numOfVertices, GpuBuffer::Type::Int); // int*    triangle start index
    vertices.d_border.create(numOfVertices, GpuBuffer::Type::Bool); // uchar*  border flags

}

void fqms::initFaces()
{
    faces.d_error.create(numOfFaces, GpuBuffer::Type::Float4);   // float4* error values
    faces.d_deleted.create(numOfFaces, GpuBuffer::Type::Bool); // uchar*  face deleted flag
    faces.d_dirty.create(numOfFaces, GpuBuffer::Type::Bool);   // uchar*  dirty flag
    faces.d_normals.create(numOfFaces ,GpuBuffer::Type::Float3); // float3* face normals

}
void fqms::initEdges()
{
    edges.d_tid.create(numOfEdges, GpuBuffer::Type::Int);      // int* triangle id per edge
    edges.d_tvertex.create(numOfEdges, GpuBuffer::Type::Int); // int* vertex id per triangle/edge

}

