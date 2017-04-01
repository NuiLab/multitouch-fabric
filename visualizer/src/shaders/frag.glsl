#version 450

/*************************************************************************
* Constants
*************************************************************************/

#define TAU 6.283185

/*************************************************************************
* Utilities
*************************************************************************/

layout(set = 0, binding = 0) uniform Block {
    vec4 mouse;
    vec2 resolution;
    float time;
    float empty; // Just empty data for contiguous data.
    float fabric[4][4];
} uniforms;

layout (location = 0) in vec2 iUV;
layout (location = 0) out vec4 oColor;

void main() {
    oColor = vec4(iUV.x, iUV.y, uniforms.time, 1.0);
}