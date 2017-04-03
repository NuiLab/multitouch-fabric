#version 450

/*************************************************************************
* Uniforms
*************************************************************************/

layout(set = 0, binding = 0) uniform Block {
    vec4 mouse;
    vec2 resolution;
    float time;
    float _padding1_;
    float fabric[4][4];
} uniforms;

layout (location = 0) in vec2 iUV;
layout (location = 0) out vec4 oColor;

/*************************************************************************
* Constants
*************************************************************************/

#define TAU 6.283185
#define EPSILON 0.00001

/*************************************************************************
* Utilities
*************************************************************************/

float saturate(float i)
{
    return clamp(i, 0., 1.);
}

/*************************************************************************
* Distance Functions
*************************************************************************/

float distSin(vec2 p, float time)
{
    float f, df, d;
    f = sin(p.y + time);
    df = (f - sin(p.y + time + EPSILON )) / EPSILON;
    d = abs(p.x - f) / sqrt(4. + df * df);
    return saturate(1.0 - smoothstep(.0, .3, d));
}

vec3 chromaSin(vec2 p, float time) {
    vec3 col = vec3(0.);
    col += vec3(distSin(p, time + (TAU / 4)), 0., 0.);
    col += vec3(0., distSin(vec2(1.1, 1.) * p, 1.1 * time + (2 * TAU / 4)), 0.);
    col += vec3(0., 0., distSin(vec2(1.2, 1.) * p, 1.2 * time + (3 * TAU / 4)));
    return col;
}
/*************************************************************************
* Main
*************************************************************************/

void main()
{
    // Setup
    vec3 col = vec3(.157, .153, .169);
    vec2 aspectRatio = vec2(1., (uniforms.resolution.y / uniforms.resolution.x));
    vec2 uv = ((iUV - vec2(.5)) * aspectRatio) + vec2(.5);
    float time = uniforms.time * 4.;

    // Sin Waves
    vec2 p = (uv - vec2(.5)) * 24.;

    col += chromaSin(p + vec2(2.5, 0.5), time);
    col += chromaSin(p + vec2(-2.5, 2.), time);
    col += chromaSin(p + vec2(7.5, 4.), time);
    col += chromaSin(p + vec2(-7.5, -3.), time);

    // Mouse Cursor
    vec2 mouse = (((uniforms.mouse.xy / uniforms.resolution) - vec2(.5)) * aspectRatio) + vec2(.5);
    float cursor = (1. - saturate(dot((uv - mouse) * 16., (uv - mouse) * 16.))) * (.5 * uniforms.mouse.z);
    col += vec3(cursor);

    oColor = vec4(col, 1.0);
}