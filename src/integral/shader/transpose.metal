//
//  simple_transpose.metal
//  iOS-Metal-HaarCascade
//
//  Created by Hoàng Xuân Quang on 7/15/17.
//  Copyright © 2017 Christopher Helf. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// transpose compute shader
kernel void transpose_function(texture2d<float, access::read>  inTexture   [[ texture(0) ]],
                               texture2d<float, access::write> outTexture  [[ texture(1) ]],
                               uint2                          gid          [[ thread_position_in_grid ]]){
    if((gid.x < outTexture.get_width()) && (gid.y < outTexture.get_height())){
        uint2 src_gid(gid.y, gid.x);
        float4 inColor  = inTexture.read(src_gid);
        outTexture.write(inColor, gid);
    }
}
