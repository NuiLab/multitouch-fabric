#version 450

/*************************************************************************
* Uniforms
*************************************************************************/

layout(set = 0, binding = 0) uniform Block {
    vec4 mouse;
    vec2 resolution;
    float time;
    float _padding1_;
    mat4 fabric;
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

//
// Description : Array and textureless GLSL 2D/3D/4D simplex 
//               noise functions.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : stegu
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//               https://github.com/stegu/webgl-noise
// 

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(vec3 v)
  { 
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
  //   x1 = x0 - i1  + 1.0 * C.xxx;
  //   x2 = x0 - i2  + 2.0 * C.xxx;
  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

// Permutations
  i = mod289(i); 
  vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
  //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
  }

vec3 colorDodge(vec3 inColor, vec3 blend)
{
    return vec3(inColor / (1.0 - blend));
}

vec3 colorOverlay(vec3 inColor, vec3 blend)
{
    vec3 outColor = vec3(0.);

    if (inColor.r > 0.5)
    {
        outColor.r = (1.0 - (1.0 - 2.0 * (inColor.r - 0.5)) * (1.0 - blend.r));
    }
    else
    {   
        outColor.r = ((2.0 * inColor.r) * blend.r);
    }

    if (inColor.g > 0.5)
    {
        outColor.g = (1.0 - (1.0 - 2.0 * (inColor.g - 0.5)) * (1.0 - blend.g));
    }
    else
    {   
        outColor.g = ((2.0 * inColor.g) * blend.g);
    }

    if (inColor.b > 0.5)
    {
        outColor.b = (1.0 - (1.0 - 2.0 * (inColor.b - 0.5)) * (1.0 - blend.b));
    }
    else
    {   
        outColor.b = ((2.0 * inColor.b) * blend.b);
    }

    return outColor;
}

float saturate(float i)
{
    return clamp(i, 0., 1.);
}

/*************************************************************************
* Distance Functions
*************************************************************************/

float distSin(vec2 p, float time, vec4 column)
{
    float f, df, d, weight, zoom;
    zoom = 1.;
    f = sin(p.y + time );
    df = (f - sin(p.y + time + EPSILON )) / EPSILON;
    weight = 1. * (
      (1.8 - smoothstep(0.0, .98 * column[0], abs(-5.5 - p.y)))
     * (1.8 - smoothstep(0.0, .98 * column[1], abs(-2. -  p.y)))
     * (1.8 - smoothstep(0.0, .98 * column[2], 1. - abs(2. - p.y)))
     * (1.8 - smoothstep(0.0, .98 * column[3], 1. - abs(5.5 - p.y)))
    );

    d = (abs(p.x * weight) - f) / sqrt(.05 + df * df);

    if (p.x < 0.)
        d = (abs(p.x * weight) + f) / sqrt(.05 + df * df);

     return 1.0 - smoothstep(.0, .1, d);
}

vec3 chromaSin(vec2 p, float time, vec4 column) {

    // Output
    vec3 col = vec3(0.);
    time *= .3;

    col += vec3(distSin(p, time + (TAU / 4), column), 0., 0.);
    col += vec3(0., distSin(vec2(1.1, 1.) * p + vec2(.1, 0.), 1.1 * -time + (2 * TAU / 4), column), 0.);
    col += vec3(0., 0., distSin(vec2(1.2, 1.) * p + vec2(.3, 0.), 1.5 * time + (3 * TAU / 4), column));
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
    vec2 uvc = (uv - vec2(.5));
    float time = uniforms.time * 4.;

    // Noise Back
    col += mix(vec3(.157, .153, .169), abs(snoise(vec3(3. * uv, time * .1)) * vec3(.1, .12, .15)), 0.5);

    // Grid Highlights
    ivec2 grid = ivec2(floor(iUV * vec2(4.)));
    col += .05 * uniforms.fabric[grid.x][grid.y];

    // Mouse Cursor
    vec2 mouse = (((uniforms.mouse.xy / uniforms.resolution) - vec2(.5)) * aspectRatio) + vec2(.5);
    float cursor = (1. - saturate(dot((uv - mouse) * 16., (uv - mouse) * 16.))) * (.5 * uniforms.mouse.z);
    col += vec3(cursor * .2);

    // Sin Waves
    vec2 p = uvc * 24.;
    //+ vec2(snoise(vec3(time * 0.13, 2.3 * uv.y, 2.92 * uv.y))) +
    // + vec2(snoise(vec3(time * 0.23, 2.3 * uv.y, 2.96 * uv.y))) 
    //+ vec2(snoise(vec3(time * 0.24, 3.04 * uv.y, 2.91 * uv.y))) 
    //+ vec2(snoise(vec3(time * 0.25, 2.8 * uv.y, 2.86 * uv.y))) 
    col += chromaSin(p  + vec2(2.5, 0.112), time, uniforms.fabric[1]);
    col += chromaSin(p + vec2(-2.5,0.11), 1.1 * time, uniforms.fabric[2]);
    col += chromaSin(p + vec2(7.5, 0.2), 1.2 * time, uniforms.fabric[0]);
    col += chromaSin(p + vec2(-7.5, 0.1), 1.3 * time, uniforms.fabric[3]);

    // Vignette
    col = mix(col, vec3(.157, .153, .169), dot(uvc * 2.5, uvc * 2.5));
    
    oColor = vec4(col, 1.0);
}