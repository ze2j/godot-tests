#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba8, binding = 0) restrict writeonly uniform image2D output_image;

void main()
{
    ivec2 coords = ivec2(gl_GlobalInvocationID.xy);
    vec2 uv = vec2(coords) / vec2(imageSize(output_image));
    vec4 data = vec4(uv, 0., 0.);
    imageStore(output_image, coords, data);
}