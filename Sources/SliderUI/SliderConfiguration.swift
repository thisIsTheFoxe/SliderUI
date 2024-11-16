//
//  SliderConfiguration.swift
//  SliderUI
//
//  Created by Henry on 16/11/2024.
//
import SwiftUI

public struct SliderConfiguration {
    let symbol: String?
    let symbolColor: Color
    let axis: SliderAxis
    let tint: Color
    let alwaysVisible: Bool
    let type: SliderType
    
    public init(symbol: String? = nil,
                symbolColor: Color = .gray,
                axis: SliderAxis = .horizontal,
                tint: Color = .white,
                alwaysVisible: Bool = false,
                type: SliderType = .basic) {
        self.symbol = symbol
        self.symbolColor = symbolColor
        self.axis = axis
        self.tint = tint
        self.alwaysVisible = alwaysVisible
        self.type = type
    }
}
