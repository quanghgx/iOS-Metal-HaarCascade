//
//  grayscale.metal
//  metal_in_macos_filter_with_swift
//
//  Created by Hoàng Xuân Quang on 7/5/17.
//  Copyright © 2017 Hoang Xuan Quang. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// Rec 709 LUMA values for grayscale image conversion
constant half3 kRec709Luma = half3(0.2126, 0.7152, 0.0722);

// Grayscale compute shader
kernel void compute_function(texture2d<half, access::read>  inTexture   [[ texture(0) ]],
                             texture2d<half, access::write> outTexture  [[ texture(1) ]],
                             uint2                          gid         [[ thread_position_in_grid ]]){

    if((gid.x < outTexture.get_width()) && (gid.y < outTexture.get_height())){
        half4 inColor  = inTexture.read(gid);
        half  gray     = dot(inColor.rgb, kRec709Luma);
        half4 outColor = half4(gray, gray, gray, 1.0);
        outTexture.write(outColor, gid);
    }
}

