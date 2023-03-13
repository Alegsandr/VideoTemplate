//
//  ImageProcessing.metal
//  Metal Test
//
//  Created by Alex on 29.11.2021.
//


#include <metal_stdlib>
#include "ImageConnect.h"

using namespace metal;


vertex Vertex vertex_render(constant Vertex *vertexes [[ buffer(0) ]],
                            constant Uniforms &uniforms [[ buffer(1) ]],
                            uint vid [[vertex_id]]) {
    
    Vertex out = vertexes[vid];
    out.position = uniforms.scaleMatrix * out.position;
    return out;
};


fragment float4 image_render(Vertex vertex_data [[stage_in]],
                             texture2d<float> texture_last  [[texture(0)]],
                             texture2d<float> texture_image [[texture(1)]],
                             texture2d<float> texture_mask  [[texture(2)]],
                             constant FrameData &frame_data [[buffer (0)]]) {

    sampler sampler;

    float4 last = float4(texture_last.sample(sampler, vertex_data.texture_coord));
    float4 image = float4(texture_image.sample(sampler, vertex_data.texture_coord));
    float4 mask = float4(texture_mask.sample(sampler, vertex_data.texture_coord));
    
    float4 image_result = image;
    
    if (frame_data.type == 0) {
        float4 image_mask = blend_filter(mask, image);
        image_result = blend_over(image_mask, last);
    }
    
    return image_result;
};

