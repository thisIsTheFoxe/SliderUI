//
//  SliderFrameModifier.swift
//  SliderUI
//
//  Created by Henry on 16/11/2024.
//

import SwiftUI

struct SliderFrameModifier: ViewModifier {
    let isDragging: Bool
    let alwaysVisible: Bool
    let compactSize: CGFloat
    let axis: SliderAxis
    
    func body(content: Content) -> some View {
        content
            .frame(
                maxWidth: axis == .horizontal || isDragging || alwaysVisible ? nil : compactSize,
                maxHeight: axis == .vertical || isDragging || alwaysVisible ? nil : compactSize,
                alignment: .topTrailing
            )
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topTrailing
            )
    }
}
