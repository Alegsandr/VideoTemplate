//
//  ServiceImageSegmentation.swift
//  VideoTemplate
//
//  Created by Alex on 3/11/23.
//

import UIKit
import Vision

protocol ServiceImageSegmentationProtocol: AnyObject {
    func makeSegmentation(image: UIImage) -> UIImage?
}

final class ServiceImageSegmentation: ServiceImageSegmentationProtocol {
    
    private var segmentationRequest: VNCoreMLRequest?
    private var visionModel: VNCoreMLModel?
    
    private lazy var segmentationModel: segmentation_8bit? = {
        let url = segmentation_8bit.urlOfModelInThisBundle
        guard let model = try? MLModel(contentsOf: url) else { return nil }
        let mlmodel = segmentation_8bit(model: model)
        return mlmodel
    }()
    
    private func setupModel() {
        if let segmentationModel = segmentationModel {
            if let visionModel = try? VNCoreMLModel(for: segmentationModel.model) {
                self.visionModel = visionModel
                segmentationRequest = VNCoreMLRequest(model: visionModel)
            }
        }
    }
    
    init() {
        setupModel()
    }
    
    
    func makeSegmentation(image: UIImage) -> UIImage? {
        segmentation(with: image)?.getImage
    }
    
    private func segmentation(with image: UIImage) -> CIImage? {
        guard let segmentationRequest = segmentationRequest else { return nil }
        guard let ciImage = CIImage(image: image.resize(CGSize(width: 1024, height: 1024))) else { return nil }

        let segmentationHandler = VNImageRequestHandler(ciImage: ciImage)
        try? segmentationHandler.perform([segmentationRequest])

        guard let segmentationObservations = segmentationRequest.results as? [VNPixelBufferObservation],
              let pixelBuffer = segmentationObservations.first?.pixelBuffer else { return nil }
        let imageResult = CIImage(cvPixelBuffer: pixelBuffer)
        
        return imageResult
    }
}
