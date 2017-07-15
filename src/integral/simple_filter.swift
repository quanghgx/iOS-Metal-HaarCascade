//
//  Created by Hoàng Xuân Quang on 7/5/17.
//  Copyright © 2017 Hoang Xuan Quang. All rights reserved.
//

import Foundation
import MetalKit
import CoreGraphics

/* Custom class for implement simple filter {grayscale, transpose, square}, those will be used
   in image integral shader. This custom implementation are alternative for Metal Performance
   Shader. Without depending on Metal Performance Shader, we can run on iOS A7 as well as
   MacOS 10.12 */
class simple_filter{

    /* grayscale encode, alternative for MPS Shader*/
    class func encode_grayscale(commandBuffer: MTLCommandBuffer, sourceTexture: MTLTexture, destinationTexture: MTLTexture){
        encode(commandBuffer: commandBuffer, sourceTexture: sourceTexture, destinationTexture: destinationTexture, function_name: "grayscale_function")
    }

    /* transpose encode, alternative for MPS Shader*/
    class func encode_transpose(commandBuffer: MTLCommandBuffer, sourceTexture: MTLTexture, destinationTexture: MTLTexture){
        encode(commandBuffer: commandBuffer, sourceTexture: sourceTexture, destinationTexture: destinationTexture, function_name: "transpose_function")
    }

    /* square encode, alternative for MPS Shader*/
    class func encode_square(commandBuffer: MTLCommandBuffer, sourceTexture: MTLTexture, destinationTexture: MTLTexture){
        encode(commandBuffer: commandBuffer, sourceTexture: sourceTexture, destinationTexture: destinationTexture, function_name: "square_function")
    }

    class private func encode(commandBuffer: MTLCommandBuffer, sourceTexture: MTLTexture, destinationTexture: MTLTexture, function_name: String){

        // pipeline state
        let pipelineState = build_pipleline_state(device: Context.device(), function_name: function_name)

        // thread group
        let w = pipelineState!.threadExecutionWidth
        let h = pipelineState!.maxTotalThreadsPerThreadgroup / w

        let threads_per_group = MTLSizeMake(w,h,1)
        let threadgroups_per_grid = MTLSize(width: (sourceTexture.width + w - 1) / w,
                                            height: (sourceTexture.height + h - 1) / h,
                                            depth: 1)

        // execuate command
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        commandEncoder.setComputePipelineState(pipelineState!)
        commandEncoder.setTexture(sourceTexture, at: 0)
        commandEncoder.setTexture(destinationTexture, at: 1)
        commandEncoder.dispatchThreadgroups(threadgroups_per_grid, threadsPerThreadgroup: threads_per_group)
        commandEncoder.endEncoding()
    }

    class private func build_pipleline_state(device: MTLDevice, function_name: String)-> MTLComputePipelineState!{
        let kernelFunction = Context.library().makeFunction(name: function_name)
        do {
            let pipelineState = try device.makeComputePipelineState(function: kernelFunction!)
            return pipelineState
        } catch let error as NSError{
            print("\(error)")
            return nil
        }
    }
}

