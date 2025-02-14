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
    color.rgb *= scaleFactor;
    color.rgb += offsetFactor;

    // Write the grayscale value to the output texture
    outTexture.write(color, gid);
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


