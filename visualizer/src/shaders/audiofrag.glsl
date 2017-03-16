#version 450

layout(set = 0, binding = 0) uniform Block {
    float time;
    bool fabric[4][4];
} uniforms;

/*************************************************************************
* Constants
*************************************************************************/

#define TAU 6.283185


/*************************************************************************
* Utilities
*************************************************************************/
// note number to frequency
float ntof(float n)
{
    return 440.0 * pow(2.0, (n - 69.0) / 12.0);
}

/*************************************************************************
* Synths
*************************************************************************/
//Sin
float synthSin(float f, float x) {
    return sin(mod(f * x * TAU, TAU));
}

float synthSquare(float f, float x)
{
    return floor( 2.0 * floor( f * x ) - floor( 2.0 * f * x ) + 1.0 );
}

float synthNoise( float x )
{
    return fract( sin( 123523.9898 * x ) * 43758.5453 );
}



layout(set = 0, binding = 0) uniform Block {
    float time;
    bool fabric[4][4];
} uniforms;

layout (location = 0) in vec2 iUV;
layout (location = 0) out vec4 oColor;

void main() {
    oColor = vec4(1.0, 0.0, 0.0, 1.0);
}