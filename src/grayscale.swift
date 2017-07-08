//
//  grayscale.swift
//  metal_in_macos_filter_with_swift
//
//  Created by Hoàng Xuân Quang on 7/5/17.
//  Copyright © 2017 Hoang Xuan Quang. All rights reserved.
//

import Foundation
import MetalKit
import CoreGraphics

class grayscale{
    class func process(device: MTLDevice, commandBuffer: MTLCommandBuffer, texture: MTLTexture, output_texture: MTLTexture){
        // 2. input texture
        print("[init] loaded texture: \(texture.width) : \(texture.height) ")
        let pipelineState = build_pipleline_state(device: device)

        // 4. thread group
        let thread_group_counts = MTLSizeMake(8,8,1)
        let thread_group = MTLSizeMake(texture.width / thread_group_counts.width,
                                       texture.height / thread_group_counts.height,
                                       1)

        let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        commandEncoder.setComputePipelineState(pipelineState!)
        commandEncoder.setTexture(texture, index: 0)
        commandEncoder.setTexture(output_texture, index: 1)
        commandEncoder.dispatchThreadgroups(thread_group, threadsPerThreadgroup: thread_group_counts)
        commandEncoder.endEncoding()
    }

    class func build_pipleline_state(device: MTLDevice)-> MTLComputePipelineState!{
        print("[init] build_pipleline_state")

        let library = device.makeDefaultLibrary()
        let kernelFunction = library?.makeFunction(name: "compute_function")

        do{
            let pipelineState = try device.makeComputePipelineState(function: kernelFunction!)
            print("[max total thread per group] \(pipelineState.maxTotalThreadsPerThreadgroup)")
            print("[thread execution width] \(pipelineState.threadExecutionWidth)")
            return pipelineState
        }catch let error as NSError{
            print("\(error)")
            return nil
        }
    }
}

