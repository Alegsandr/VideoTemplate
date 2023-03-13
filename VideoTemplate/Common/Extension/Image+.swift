//
//  Image+.swift
//  VideoTemplate
//
//  Created by Alex on 3/11/23.
//

import UIKit

extension CIImage {
    
    var getImage: UIImage {
        let context = CIContext(options: [CIContextOption.cacheIntermediates: false, CIContextOption.highQualityDownsample: false])
        guard let cgImage = context.createCGImage(self, from: extent) else { return UIImage() }
        return UIImage(cgImage: cgImage)
    }
}

extension UIImage {
    
    func toPixelBuffer(_ IOSurface: Bool = false) -> CVPixelBuffer? {
        let width = self.size.width
        let height = self.size.height
        
        var attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue as Any,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue as Any] as CFDictionary
        
        if IOSurface {
            attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue as Any,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue as Any,
                     String(kCVPixelBufferIOSurfacePropertiesKey): ["IOSurfaceOpenGLESFBOCompatibility": true,
                                                                    "IOSurfaceOpenGLESTextureCompatibility": true,
                                                                    "IOSurfaceCoreAnimationCompatibility": true]] as CFDictionary
        }
        
        var pixelBuffer: CVPixelBuffer?
    
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_32BGRA,
                                         attrs,
                                         &pixelBuffer)
        
        guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {return nil}
        CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let bitmapInfo = CGBitmapInfo(
            rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        )
        
        let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else {return nil}
        
        context.translateBy(x: 0, y: height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

        return resultPixelBuffer
    }
    
    func resize(_ size: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
            
        return image.withRenderingMode(renderingMode)
    }
}
