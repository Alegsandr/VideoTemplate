//
//  Texture.swift
//  VideoTemplate
//
//  Created by Alex on 3/11/23.
//

import Metal

struct Texture {
    
    let texture: MTLTexture
    let textureKey: String
    
    public init(texture: MTLTexture, textureKey: String = "") {
        self.texture = texture
        self.textureKey = textureKey
    }

    public init(width: Int, height: Int, pixelFormat: MTLPixelFormat = .bgra8Unorm, textureKey: String = "") {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
                                                                         width: width,
                                                                         height: height,
                                                                         mipmapped: false)
        textureDescriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]

        guard let newTexture = RenderDevice.device.makeTexture(descriptor: textureDescriptor) else { fatalError("") }
        self.texture = newTexture
        self.textureKey = textureKey
    }
}

