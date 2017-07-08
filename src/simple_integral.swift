//
//  simple_integral.swift
//  metal_in_macos_filter_with_swift
//
//  Created by Hoàng Xuân Quang on 7/8/17.
//  Copyright © 2017 Hoang Xuan Quang. All rights reserved.
//

import Foundation
import MetalKit

class simple_integral{
    class func integral(device: MTLDevice, grayscaleTex: MTLTexture) -> MTLTexture{
        let width = grayscaleTex.width
        let height = grayscaleTex.height
        let gray_aray = textureToArray(texture: grayscaleTex)
        let i_aray = integral_image(img: gray_aray, width:width, height: height)

        return createTexture(device: device, format: .r32Float, width: width, height: height, bytes: i_aray)
    }

    class func square_integral(device: MTLDevice, grayscaleTex: MTLTexture) -> MTLTexture{
        let width = grayscaleTex.width
        let height = grayscaleTex.height
        let gray_aray = textureToArray(texture: grayscaleTex)
        let si_aray = squared_integral_image(img: gray_aray, width:width, height: height)

        return createTexture(device: device, format: .r32Float, width: width, height: height, bytes: si_aray)
    }
    
    class func simple_test(){
        let image:[Float] = [
            1, 2, 3, 4,
            5, 6, 7, 8,
            9, 10, 11, 12
        ]

        print("original image")
        display(img: image, width: 4, height: 3)

        let iimg = integral_image(img: image, width: 4, height: 3)
        print("integral image")
        display(img: iimg, width: 4, height: 3)

        let siimg = squared_integral_image(img: image, width: 4, height: 3)
        print("square integral image")
        display(img: siimg, width: 4, height: 3)
    }

    class func squared_integral_image(img: [Float], width: Int, height: Int ) -> [Float]{
        var ii = [Float](repeatElement(0.0, count: width*height))
        var s = [Float](repeatElement(0.0, count: width*height))

        for y in 0...(height-1) {
            for x in 0...(width-1){
                if (x == 0) {
                    s[(y * width) + x] = pow(img[(y * width) + x],2)
                }else {
                    s[(y * width) + x] = s[(y * width) + x - 1] + pow(img[(y * width) + x],2)
                }
                if (y == 0) {
                    ii[(y * width) + x] = s[(y * width) + x]
                } else {
                    ii[(y * width) + x] = ii[((y - 1) * width) + x] + s[(y * width) + x]
                }
            }
        }

        return ii
    }

    class func integral_image(img: [Float], width: Int, height: Int ) -> [Float]{
        var ii = [Float](repeatElement(0.0, count: width*height))
        var s = [Float](repeatElement(0.0, count: width*height))

        for y in 0...(height-1) {
            for x in 0...(width-1){
                if (x == 0) {
                    s[(y * width) + x] = img[(y * width) + x]
                }else {
                    s[(y * width) + x] = s[(y * width) + x - 1] + img[(y * width) + x]
                }
                if (y == 0) {
                    ii[(y * width) + x] = s[(y * width) + x]
                } else {
                    ii[(y * width) + x] = ii[((y - 1) * width) + x] + s[(y * width) + x]
                }
            }
        }

        return ii
    }

    class func display(img: [Float], width: Int, height: Int ) {
        var result:String = ""
        for y in 0...(height-1){
            for x in 0...(width-1){
                result +=  String(img[y * width + x]) + " "
            }
            result += "\n"
        }
        print("\(result)")
    }

    class func createTexture(device: MTLDevice, format: MTLPixelFormat, width: Int, height: Int, bytes: [Float]) -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: format, width: width, height: height, mipmapped: false)
        descriptor.resourceOptions = MTLResourceOptions.storageModeShared
        descriptor.storageMode = MTLStorageMode.shared

        let t = device.makeTexture(descriptor: descriptor)
        t.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: bytes, bytesPerRow: width*4)
        return t
    }

    class func textureToArray(texture: MTLTexture) -> [Float] {
        let bytesPerRow = texture.width*MemoryLayout<Float>.size
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        var vals = [Float](repeatElement(0.0, count: texture.width*texture.height))
        texture.getBytes(&vals, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        return vals;
    }
}
