//
//  ServiceMakeVideo.swift
//  VideoTemplate
//
//  Created by Alex on 3/11/23.
//

import AVFoundation
import CoreImage
import UIKit

final class ServiceMakeVideo {
    
    static func create(images: [UIImage], completion: @escaping (URL) -> Void) {
        let settings = RenderSettings(size: images.first?.size ?? .zero, fps: 1, avCodecKey: .h264, filename: "video_template", extension: "mov")
        
        let imageAnimator = ImageAnimator(renderSettings: settings)
        imageAnimator.images = images.map { $0.size == images.first?.size ? $0 : $0.resize(images.first?.size ?? .zero) }
        imageAnimator.render() { url in
            completion(settings.outputURL)
        }
    }
    
    static func getVideo(url: URL) -> AVAssetReaderTrackOutput? {
        let asset = AVAsset(url: url)
        
        guard let reader = try? AVAssetReader(asset: asset) else { return nil }
        guard let track = asset.tracks(withMediaType: .video).last else { return nil }
        
        let outputSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        reader.add(output)
        reader.startReading()
        
        return output
    }
}


private struct RenderSettings {
    
    let size: CGSize
    let fps: Int32
    let avCodecKey: AVVideoCodecType
    let filename: String
    var `extension`: String
    
    
    var outputURL: URL {
        let fileManager = FileManager.default
        if let tmpDirURL = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            return tmpDirURL.appendingPathComponent(filename).appendingPathExtension(`extension`)
        }
        
        fatalError()
    }
}


private final class ImageAnimator {
    
    static let kTimescale: Int32 = 600
    
    var images: [UIImage]!
    
    private let renderSettings: RenderSettings
    private let videoWriter: VideoWriter
    private var counter = 0

    
    init(renderSettings: RenderSettings) {
        self.renderSettings = renderSettings
        videoWriter = VideoWriter(renderSettings: renderSettings)
    }
    
    func render(completion: ((URL) -> Void)?) {
        removeFileAtURL(fileURL: renderSettings.outputURL)
        
        videoWriter.start()
        videoWriter.render(appendPixelBuffers: appendPixelBuffers) {
            completion?(self.renderSettings.outputURL)
        }
    }
    
    private func removeFileAtURL(fileURL: URL) {
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
        } catch {}
    }
    
    private func appendPixelBuffers(writer: VideoWriter) -> Bool {
        let frameDuration = CMTimeMake(value: Int64(ImageAnimator.kTimescale / renderSettings.fps), timescale: ImageAnimator.kTimescale)
        
        while !images.isEmpty {
            if !writer.isReadyForData { return false }
            
            let image = images.removeFirst()
            let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(counter))
            videoWriter.addImage(image: image, withPresentationTime: presentationTime)

            counter += 1
        }
        
        return true
    }
}

private final class VideoWriter {
    
    private let renderSettings: RenderSettings
    
    private var videoWriter: AVAssetWriter!
    private var videoWriterInput: AVAssetWriterInput!
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    
    var isReadyForData: Bool {
        return videoWriterInput?.isReadyForMoreMediaData ?? false
    }
    
    static func pixelBufferFromImage(image: UIImage, pixelBufferPool: CVPixelBufferPool, size: CGSize) -> CVPixelBuffer {
        var pixelBufferOut: CVPixelBuffer?
        
        let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pixelBufferOut)
        if status != kCVReturnSuccess { fatalError() }
        
        let pixelBuffer = pixelBufferOut!
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let data = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: data, width: Int(size.width), height: Int(size.height),
                                bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        context?.clear(CGRect(origin: .zero, size: size))
        
        let horizontalRatio = size.width / image.size.width
        let verticalRatio = size.height / image.size.height
        let aspectRatio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
        
        let x = newSize.width < size.width ? (size.width - newSize.width) / 2 : 0
        let y = newSize.height < size.height ? (size.height - newSize.height) / 2 : 0
        
        context?.draw(image.cgImage!, in: CGRect(x:x,y: y, width: newSize.width, height: newSize.height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    init(renderSettings: RenderSettings) {
        self.renderSettings = renderSettings
    }
    
    
    func start() {
        let avOutputSettings: [String: Any] = [
            AVVideoCodecKey: renderSettings.avCodecKey,
            AVVideoWidthKey: NSNumber(value: Float(renderSettings.size.width)),
            AVVideoHeightKey: NSNumber(value: Float(renderSettings.size.height))
        ]
        
        func createPixelBufferAdaptor() {
            let sourcePixelBufferAttributesDictionary = [
                kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: NSNumber(value: Float(renderSettings.size.width)),
                kCVPixelBufferHeightKey as String: NSNumber(value: Float(renderSettings.size.height))
            ]
            
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput,
                                                                      sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        }
        
        func createAssetWriter(outputURL: URL) -> AVAssetWriter {
            guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mp4) else { fatalError() }
            guard assetWriter.canApply(outputSettings: avOutputSettings, forMediaType: AVMediaType.video) else { fatalError() }
            return assetWriter
        }
        
        videoWriter = createAssetWriter(outputURL: renderSettings.outputURL)
        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: avOutputSettings)
        
        if videoWriter.canAdd(videoWriterInput) {
            videoWriter.add(videoWriterInput)
        }
        
        createPixelBufferAdaptor()
        
        if !videoWriter.startWriting() { fatalError() }
        
        videoWriter.startSession(atSourceTime: CMTime.zero)
    }
    
    func render(appendPixelBuffers: ((VideoWriter) -> Bool)?, completion: (() -> Void)?) {
        let queue = DispatchQueue(label: "queue.writer.video")
        videoWriterInput.requestMediaDataWhenReady(on: queue) {
            let isFinished = appendPixelBuffers?(self) ?? false
            
            if isFinished {
                self.videoWriterInput.markAsFinished()
                self.videoWriter.finishWriting() {
                    DispatchQueue.main.async {
                        completion?()
                    }
                }
            }
        }
    }
    
    func addImage(image: UIImage, withPresentationTime presentationTime: CMTime) {
        let pixelBuffer = VideoWriter.pixelBufferFromImage(image: image, pixelBufferPool: pixelBufferAdaptor.pixelBufferPool!, size: renderSettings.size)
        pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
    }
}
