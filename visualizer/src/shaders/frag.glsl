#version 450

layout(set = 0, binding = 0) uniform Block {
    float time;
    float fabric[8][8];
} uniforms;

layout (location = 0) in vec2 iUV;
layout (location = 0) out vec4 oColor;

void main() {
    oColor = vec4(1.0, 0.0, 0.0, 1.0);
}