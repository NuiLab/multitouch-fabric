// Frag Shader
#version 450

#extension GL_ARB_separate_shader_objects : enable

layout(set = 0, binding = 0) uniform Time {
    float value;
} uTime;
layout(set = 0, binding = 1) uniform Fabric {
    float value[8][8];
} uFabric;

layout (location = 0) in vec2 iUV;
layout (location = 0) out vec4 oColor;

void main() {
    oColor = vec4(1.0, 0.0, 0.0, 1.0);
}