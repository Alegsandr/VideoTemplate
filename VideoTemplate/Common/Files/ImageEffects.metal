//
//  ImageEffects.metal
//  VideoTemplate
//
//  Created by Alex on 3/3/23.
//

#include <metal_stdlib>
#include "ImageConnect.h"

using namespace metal;

template <typename T, typename _E = typename enable_if<is_floating_point<typename make_scalar<T>::type>::value>::type>
METAL_FUNC T mod(T x, T y) {
    return x - y * floor(x/y);
}

float4 image_scale(texture2d<float> texture, float2 coord, float scale) {
    sampler sampler;
    float2 scale_value = (2 - scale) * (coord - 0.5) + 0.5;
    return texture.sample(sampler, scale_value);
}

float4 image_rotate(texture2d<float> texture, float degree) {
    sampler sampler;
    float2 value = float2(sin(degree), cos(degree)) + 0.5;
    return texture.sample(sampler, value);
}

float4 image_rotate(texture2d<float> texture, float2 coord, float angle) {
    sampler sampler;
    const float magnitude = sin(60.0) * 0.1 * angle;
    
    float2 image_coordinate = float2(coord.x + magnitude, coord.y);
    float4 image_result = texture.sample(sampler, image_coordinate);
    
    return image_result;
}

float2 image_effect(float2 texture_coord, float angle, float scale) {
    float cr = cos(angle);
    float sr = sin(angle);
    float2x2 m = float2x2(float2(cr, -sr), float2(sr, cr));
    
    float2 rotated_texture_coordinate = m * texture_coord;
    return (rotated_texture_coordinate - mod(rotated_texture_coordinate, float2(scale)) + scale * 0.5) * m;
}
