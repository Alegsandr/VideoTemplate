//
//  DataFrame.swift
//  VideoTemplate
//
//  Created by Alex on 3/11/23.
//

import simd

enum ImageType: Int {
    case image = 0
    case mask = 1
}

enum OverlayStyle: Int {
    case none = 0
    case scale = 1
}

struct DataFrame {
    let type: ImageType
    let overlayStyle: OverlayStyle
    let size: vector_float2
}

struct ModelFrame {
    let image: (last: Texture?, image: Texture?, mask: Texture?)?
    var data: DataFrame?
}
