//
//  TemplatePresenter.swift
//  VideoTemplate
//
//  Created by Alex on 3/11/23.
//

import UIKit

protocol TemplatePresenterProtocol: AnyObject {
    init(view: TemplateViewControllerProtocol,
         serviceImageSegmentation: ServiceImageSegmentationProtocol,
         serviceSound: ServiceSoundProtocol)
    
    func segmentationImage(_ image: UIImage) -> UIImage?
    
    typealias ValueImages = (last: UIImage?, image: UIImage, mask: UIImage, type: ImageType)
    typealias ValueTextures = (last: Texture?, image: Texture?, mask: Texture?, type: ImageType)
    
    func textures(from images: ValueImages) -> ValueTextures
    func startMake(images: [(UIImage, ImageType)?], speed: Double, completion: @escaping (Texture?, ImageType) -> Void, update: @escaping (Bool) -> Void)
    
    func playMusic()
    func pauseMusic()
}


final class TemplatePresenter: TemplatePresenterProtocol {
        
    private weak var view: TemplateViewControllerProtocol?
    private let serviceImageSegmentation: ServiceImageSegmentationProtocol
    private let serviceSound: ServiceSoundProtocol
    
    private let textureGenerator = TextureGenerator()

    
    required init(view: TemplateViewControllerProtocol,
                  serviceImageSegmentation: ServiceImageSegmentationProtocol,
                  serviceSound: ServiceSoundProtocol) {
        self.view = view
        self.serviceImageSegmentation = serviceImageSegmentation
        self.serviceSound = serviceSound
    }
    
    func segmentationImage(_ image: UIImage) -> UIImage? {
        serviceImageSegmentation.makeSegmentation(image: image)
    }
    
    func textures(from images: ValueImages) -> ValueTextures {
        if let pixelBuffer = images.image.toPixelBuffer(true), let pixelBufferMask = images.mask.toPixelBuffer(true) {
            if let pixelBufferLast = images.last?.toPixelBuffer(true) {
                return (textureGenerator.texture(from: pixelBufferLast),
                        textureGenerator.texture(from: pixelBuffer),
                        textureGenerator.texture(from: pixelBufferMask), images.type)
            }
            
            return (nil, textureGenerator.texture(from: pixelBuffer), textureGenerator.texture(from: pixelBufferMask), images.type)
        }

        return (nil, nil, nil, .image)
    }
    
    func playMusic() {
        serviceSound.play(name: "music", extension: .aac)
    }
    
    func pauseMusic() {
        serviceSound.pause()
    }
    
    
    //MARK: - Сделать, если успею вместо метода выше
    func startMake(images: [(UIImage, ImageType)?], speed: Double, completion: @escaping (Texture?, ImageType) -> Void, update: @escaping (Bool) -> Void) {
        var counter = 0
        
        ServiceMakeVideo.create(images: images.compactMap { $0?.0 }) { url in
            guard let output = ServiceMakeVideo.getVideo(url: url) else { return }
            var sampleBuffer = output.copyNextSampleBuffer()
            
            while sampleBuffer != nil {
                if let sampleBuffer = sampleBuffer {
                    let texture = self.textureGenerator.texture(from: sampleBuffer)
                    completion(texture, images[safe: counter]??.1 ?? .image)
                }
                                
                counter += 1
                update(images[safe: counter] != nil)
                
                if images[safe: counter] == nil {
                    
                }
                
                sampleBuffer = output.copyNextSampleBuffer()
                
                RunLoop.current.run(until: Date() + speed)
            }
        }
    }
}
