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
    class func process(commandBuffer: MTLCommandBuffer, sourceTexture: MTLTexture, destinationTexture: MTLTexture){
        // 2. input texture
        print("[init] grayscale texture: \(sourceTexture.width) : \(sourceTexture.height) \(sourceTexture.description)")

        let pipelineState = build_pipleline_state(device: Context.device())

        // 4. thread group
        let w = pipelineState!.threadExecutionWidth
        let h = pipelineState!.maxTotalThreadsPerThreadgroup / w

        let threads_per_group = MTLSizeMake(w,h,1)
        let threadgroups_per_grid = MTLSize(width: (sourceTexture.width + w - 1) / w,
                                            height: (sourceTexture.height + h - 1) / h,
                                            depth: 1)

        let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        commandEncoder.setComputePipelineState(pipelineState!)
        commandEncoder.setTexture(sourceTexture, at: 0)
        commandEncoder.setTexture(destinationTexture, at: 1)
        commandEncoder.dispatchThreadgroups(threadgroups_per_grid, threadsPerThreadgroup: threads_per_group)
        commandEncoder.endEncoding()
    }

    class func build_pipleline_state(device: MTLDevice)-> MTLComputePipelineState!{
        print("[init] build_pipleline_state")

        let kernelFunction = Context.library().makeFunction(name: "grayscale_function")

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

