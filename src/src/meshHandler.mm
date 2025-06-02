// meshHandler.mm
#import "meshHandler.h"
#import <MetalKit/MetalKit.h>

using namespace std;

MeshHandler::MeshHandler(id<MTLDevice> device) : m_device(device) {}

bool MeshHandler::readPLY(const string &path)
{
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:path.c_str()]];
    if (!url) return false;

    // Allocate using MetalKit so we can share buffers, but keep CPU copies too.
    MTKMeshBufferAllocator *alloc = [[MTKMeshBufferAllocator alloc] initWithDevice:m_device];
    MDLAsset *asset = [[MDLAsset alloc] initWithURL:url
                                   vertexDescriptor:nil
                                   bufferAllocator:alloc];
    if (asset.count == 0) return false;
    MDLMesh *mdl = (MDLMesh*)asset[0];

    auto *posAttr = [mdl vertexAttributeDataForAttributeNamed:MDLVertexAttributePosition];
    if (!posAttr || posAttr.format != MDLVertexFormatFloat3) return false;

    const uint8_t* raw = (const uint8_t*)posAttr.dataStart;
    m_vertices.resize(mdl.vertexCount);

    for (NSUInteger i = 0; i < mdl.vertexCount; ++i) {
        const simd::float3* ptr = (const simd::float3*)(raw + i * posAttr.stride);
        m_vertices[i] = *ptr;
    }
//    simd::float3* start = (simd::float3*)posAttr.dataStart;
//    m_vertices.assign(start, start + mdl.vertexCount);
    
    // Concatenate indices of all submeshes (assume triangles)
    m_indices.clear();
    for (MDLSubmesh *sub in mdl.submeshes) {
        MDLMeshBufferMap *map = [[sub indexBuffer] map];          // map is a property, not a function
        const void *idata     = map.bytes;
        NSUInteger icount     = sub.indexCount;
        if (sub.indexType == MDLIndexBitDepthUInt32) {
            const uint32_t *p = (const uint32_t*)idata;
            m_indices.insert(m_indices.end(), p, p + icount);
        } else if (sub.indexType == MDLIndexBitDepthUInt16) {
            const uint16_t *p = (const uint16_t*)idata;
            for (NSUInteger i = 0; i < icount; ++i) m_indices.push_back(p[i]);
        } else {
            return false; // unsupported
        }
    }
    return true;
}

bool MeshHandler::writePLY(const string &path) const
{
//    if (m_vertices.empty() || m_indices.empty()) return false;
//
//    // Build an MDLMesh from our data
//    MDLMesh *mdl = [[MDLMesh alloc] initWithVertexBuffer:nil vertexCount:m_vertices.size() vertexDescriptor:nil submeshes:nil];
//
//    // Create vertex buffer
//    NSData *vData = [NSData dataWithBytes:m_vertices.data() length:m_vertices.size()*sizeof(simd::float3)];
//    MDLVertexBufferLayout *layout = [[MDLVertexBufferLayout alloc] initWithStride:sizeof(simd::float3)];
//    MDLVertexAttribute *posAttr = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributePosition format:MDLVertexFormatFloat3 offset:0 bufferIndex:0];
//    mdl.vertexDescriptor = [[MDLVertexDescriptor alloc] init];
//    mdl.vertexDescriptor.layouts[0] = layout;
//    mdl.vertexDescriptor.attributes[0] = posAttr;
//    MDLMeshBufferData *vbuf = [[MDLMeshBufferData alloc] initWithData:vData type:MDLMeshBufferTypeVertex];
//    [mdl setVertexBuffer:vbuf index:0];
//
//    // Index buffer
//    NSData *iData = [NSData dataWithBytes:m_indices.data() length:m_indices.size()*sizeof(uint32_t)];
//    MDLMeshBufferData *idxBuf = [[MDLMeshBufferData alloc] initWithData:iData type:MDLMeshBufferTypeIndex];
//    MDLSubmesh *sub = [[MDLSubmesh alloc] initWithName:@"all" indexBuffer:idxBuf indexCount:m_indices.size() indexType:MDLIndexBitDepthUInt32 geometryType:MDLGeometryTypeTriangles material:nil];
//    mdl.submeshes = @[sub];
//
//    MDLAsset *exportAsset = [[MDLAsset alloc] init];
//    [exportAsset addMesh:mdl];
//    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:path.c_str()]];
//    return [exportAsset exportAssetToURL:url];
}


void MeshHandler::clear()
{
    m_vertices.clear();
    m_indices.clear();
}
