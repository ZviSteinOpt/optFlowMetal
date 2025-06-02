#include <metal_stdlib>
using namespace metal;

// Convert RGB to Grayscale using equal weights
kernel void rgbToGrayscale(
    texture2d<float, access::read> inTexture [[texture(0)]],
    texture2d<float, access::write> outTexture [[texture(1)]],
    constant float &scaleFactor [[buffer(2)]],
    constant float &offsetFactor [[buffer(3)]],
    uint2 gid [[thread_position_in_grid]])
{
    // Ensure the thread is within the texture bounds
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) {
        return;
    }

    // Sample the input texture at the current position
    float4 color = inTexture.read(gid);
    
    // Convert RGB to grayscale using proper weighting
    float grayscale = (color.r + color.g + color.b) / 3.0; // Equal weights

    // Apply scale and offset (optional)
    grayscale = grayscale * scaleFactor + offsetFactor;

    // Write grayscale value to output texture (preserve alpha)
    outTexture.write(float4(grayscale, grayscale, grayscale, color.a), gid);
}

// Modify the input texture by dividing RGB values and converting to grayscale
kernel void scale(
    texture2d<float, access::read_write> texture [[texture(0)]],  // Read and write on the same texture
    constant float &scaleFactor [[buffer(1)]],
    uint2 gid [[thread_position_in_grid]])
{
    // Ensure the thread is within the texture bounds
    if (gid.x >= texture.get_width() || gid.y >= texture.get_height()) {
        return;
    }

    // Sample the texture at the current position
    float4 color = texture.read(gid);

    color.rgb *= scaleFactor;
    texture.write(color, gid);
}

// Modify the input texture by dividing RGB values and converting to grayscale
kernel void offset(
    texture2d<float, access::read_write> texture [[texture(0)]],  // Read and write on the same texture
    constant float &scaleFactor [[buffer(1)]],
    uint2 gid [[thread_position_in_grid]])
{
    // Ensure the thread is within the texture bounds
    if (gid.x >= texture.get_width() || gid.y >= texture.get_height()) {
        return;
    }

    // Sample the texture at the current position
    float4 color = texture.read(gid);

    color.rgb += scaleFactor;
    texture.write(color, gid);
}

inline float j_laplacian(texture2d<float, access::read> img,
                         texture2d<float, access::read> reg,
                         texture2d<float, access::read> rhs,
                         uint2                        gid)
{
    /* centre values (use red channel) */
    float  rv = reg.read(gid).r;
    float  b  = rhs.read(gid).r;

    /* 8-neighbour fetches (replicate edge manually) */
    float l  = img.read(uint2(gid.x - 1, gid.y    )).r;
    float r  = img.read(uint2(gid.x + 1, gid.y    )).r;
    float u  = img.read(uint2(gid.x    , gid.y - 1)).r;
    float d  = img.read(uint2(gid.x    , gid.y + 1)).r;

    float ul = img.read(uint2(gid.x - 1, gid.y - 1)).r;
    float ur = img.read(uint2(gid.x + 1, gid.y - 1)).r;
    float dl = img.read(uint2(gid.x - 1, gid.y + 1)).r;
    float dr = img.read(uint2(gid.x + 1, gid.y + 1)).r;

    float neighbourSum = (l + r + u + d + ul + ur + dl + dr) * (-1.0f / 3.0f);

    /* Ax in Jacobi (with regularisation term rv) */
    float Ax = (b - neighbourSum) / ((8.0f / 3.0f) + rv);
    return Ax;
}

kernel void weightedJacoby(texture2d<float, access::write> xNew  [[texture(0)]],
                           texture2d<float, access::read>  b     [[texture(1)]],
                           texture2d<float, access::read>  xPrev [[texture(2)]],
                           texture2d<float, access::read>  reg   [[texture(3)]],
                           constant float&               omega   [[buffer(4)]],
                           uint2                         gid     [[thread_position_in_grid]])
{
    /* bounds guard: stop threads that walk off the image */
    if (gid.x >= xNew.get_width() || gid.y >= xNew.get_height()) {
        return;
    }

    /* your own stencil routine – assumed to return a scalar */
    float Ax       = j_laplacian(xPrev, reg, b, gid);

    /* take the red (only) component from the textures */
    float residual = b.read(gid).r - Ax;
    float updated  = xPrev.read(gid).r + omega * residual;

    xNew.write(updated, gid);          // writes a scalar pixel
}


kernel void countFaces(device const int3*     faces       [[ buffer(0) ]],
                       device const uchar*    deleted     [[ buffer(1) ]],
                       device atomic_int*     tcount      [[ buffer(2) ]],
                       uint                   gid         [[ thread_position_in_grid ]]) {
    
    if (deleted[gid]) return; // skip deleted faces

    int3 f = faces[gid]; // 3 vertex indices
    atomic_fetch_add_explicit(&tcount[f.x], 1, memory_order_relaxed);
    atomic_fetch_add_explicit(&tcount[f.y], 1, memory_order_relaxed);
    atomic_fetch_add_explicit(&tcount[f.z], 1, memory_order_relaxed);
}
