//
//  ImageBlend.metal
//  VideoTemplate
//
//  Created by Alex on 3/3/23.
//

#include <metal_stdlib>
#include "ImageConnect.h"

using namespace metal;

float4 blend_filter(float4 map, float4 image) {
    float4 image_result = float4(map.rgb * image.rgb, map.r * map.g * map.b);
    return image_result;
}

float4 blend_over(float4 foreground, float4 background) {
    float4 image_result = background.rgba * (1-foreground.a) + foreground.rgba;
    return image_result;
}
