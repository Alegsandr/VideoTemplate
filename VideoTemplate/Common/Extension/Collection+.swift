//
//  Collection+.swift
//  VideoTemplate
//
//  Created by Alex on 3/11/23.
//


extension Collection {
    
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
