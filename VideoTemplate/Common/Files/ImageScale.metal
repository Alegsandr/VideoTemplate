//
//  ImageScale.metal
//  VideoTemplate
//
//  Created by Alex on 3/10/23.
//

#include <metal_stdlib>
using namespace metal;

float4 aspect_fit(float2 coord, texture2d<float> texture, sampler sampler, float2 size) {
    float texture_aspect = (float)texture.get_width() / (float)texture.get_height();
    float frame_aspect = (float)size.y / (float)size.x;

    float scaleX = 1, scaleY = 1;
    float texture_ratio = texture_aspect / frame_aspect;
    bool is_portrait = frame_aspect < 1;

    if (is_portrait) {
        scaleY = texture_ratio;
    } else {
        scaleX = 1.f / texture_ratio;
    }

    float2 texture_scale = float2(scaleX, scaleY);
    float2 texture_coord = texture_scale * (coord - 0.5) + 0.5;

    return texture.sample(sampler, texture_coord);
}
