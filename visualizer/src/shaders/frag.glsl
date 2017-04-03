#version 450

/*************************************************************************
* Constants
*************************************************************************/

#define TAU 6.283185

/*************************************************************************
* Utilities
*************************************************************************/

float saturate(float i)
{
    return clamp(i, 0., 1.);
}

layout(set = 0, binding = 0) uniform Block {
    vec4 mouse;
    vec2 resolution;
    float time;
    float _padding1_;
    float fabric[4][4];
} uniforms;

layout (location = 0) in vec2 iUV;
layout (location = 0) out vec4 oColor;

void main()
{
    oColor = vec4(.157, .153, .169, 1.0);
    // Setup
    vec2 aspectRatio = vec2(1., (uniforms.resolution.y / uniforms.resolution.x));
    vec2 uv = ((iUV - vec2(.5)) * aspectRatio) + vec2(.5);

    // Mouse Cursor
    vec2 mouse = (((uniforms.mouse.xy / uniforms.resolution) - vec2(.5)) * aspectRatio) + vec2(.5);
    float cursor = (1. - saturate(dot((uv - mouse) * 16., (uv - mouse) * 16.))) * (.5 * uniforms.mouse.z);
    oColor.xyz += vec3(cursor);
}