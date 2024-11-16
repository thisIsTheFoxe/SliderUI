//
//  SliderConstants.swift
//  SliderUI
//
//  Created by Henry on 16/11/2024.
//
import Foundation

struct SliderConstants {
    let widthScale: CGFloat
    let heightScale: CGFloat
    let limitation: CGFloat
    let stretchiness: CGFloat
    let scalieness: CGFloat
    let compactSize: CGFloat
    
    init(widthScale: CGFloat = 2,
         heightScale: CGFloat = 1.5,
         limitation: CGFloat = 0.25,
         stretchiness: CGFloat = 0.15,
         scalieness: CGFloat = 0.25,
         compactSize: CGFloat = 8) {
        self.widthScale = widthScale
        self.heightScale = heightScale
        self.limitation = limitation
        self.stretchiness = stretchiness
        self.scalieness = scalieness
        self.compactSize = compactSize
    }
}
