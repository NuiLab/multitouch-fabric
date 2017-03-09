#version 450

layout(location = 0) in vec2 iPosition;
layout (location = 1) in vec2 iUV;
layout (location = 0) out vec2 oUV;

void main() {
    oUV = iUV;
    gl_Position = vec4(iPosition, 0.0, 1.0);
}