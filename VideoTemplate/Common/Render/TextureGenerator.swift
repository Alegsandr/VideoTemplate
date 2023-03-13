//
//  TextureGenerator.swift
//  VideoTemplate
//
//  Created by Alex on 3/11/23.
//

import CoreMedia

final class TextureGenerator: NSObject {
    
    public let sourceKey: String
    var videoTextureCache: CVMetalTextureCache?
    
    public init(sourceKey: String = "camera") {
        self.sourceKey = sourceKey
        super.init()

        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, RenderDevice.device, nil, &videoTextureCache)
    }
    
    func texture(from cameraFrame: CVPixelBuffer) -> Texture? {
        guard let videoTextureCache = videoTextureCache else { return nil }
        
        let bufferWidth = CVPixelBufferGetWidth(cameraFrame)
        let bufferHeight = CVPixelBufferGetHeight(cameraFrame)

        var textureRef: CVMetalTexture? = nil
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                  videoTextureCache,
                                                  cameraFrame,
                                                  nil,
                                                  .bgra8Unorm,
                                                  bufferWidth,
                                                  bufferHeight,
                                                  0,
                                                  &textureRef)
        
        if let texture = textureRef, let cameraTexture = CVMetalTextureGetTexture(texture) {
            return Texture(texture: cameraTexture, textureKey: sourceKey)
        } else {
            return nil
        }
    }
    
    func texture(from sampleBuffer: CMSampleBuffer) -> Texture? {
        guard let cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        return texture(from: cameraFrame)
    }
}
