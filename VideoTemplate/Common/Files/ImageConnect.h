//
//  ImageConnect.h
//  Metal Test
//
//  Created by Alex on 01.12.2021.
//

#define ImageConnect_h
using namespace metal;


struct Vertex {
    float4 position [[position]];
    float2 texture_coord;
};

struct Uniforms {
    float4x4 scaleMatrix;
};

struct FrameData {
    int type;
    int style;
    float2 size;
};


float4 aspect_fit(float2 coord, texture2d<float> texture, sampler sampler, float2 size);
float2 image_effect(float2 texture_coord, float angle, float scale);

float4 image_scale(texture2d<float> texture, float2 coord, float scale);
float4 image_rotate(texture2d<float> texture, float degree);
float4 image_rotate(texture2d<float> texture, float2 coord, float angle);


float4 blend_filter(float4 foreground, float4 background);
float4 blend_over(float4 foreground, float4 background);
