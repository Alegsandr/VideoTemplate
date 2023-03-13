//
//  ServiceAssembly.swift
//  VideoTemplate
//
//  Created by Alex on 3/11/23.
//

import Foundation

struct ServicesAssebly {
    
    static let serviceImageSegmentation: ServiceImageSegmentationProtocol = {
        ServiceImageSegmentation()
    }()
    
    static let serviceSound: ServiceSoundProtocol = {
        ServiceSound()
    }()
}
