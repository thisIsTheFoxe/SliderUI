//
//  CenteredSliderFill.swift
//  SliderUI
//
//  Created by Henry on 16/11/2024.
//

import SwiftUI

struct CenteredSliderFill: View {
    let orientationSize: CGFloat
    let progressValue: CGFloat
    let progress: CGFloat
    let axis: SliderAxis
    let tint: Color
    
    var body: some View {
        Rectangle()
            .fill(tint)
            .frame(
                width: axis == .horizontal ? orientationSize * 0.05 : nil,
                height: axis == .vertical ? orientationSize * 0.05 : nil
            )
        
        Rectangle()
            .fill(tint)
            .frame(
                width: axis == .horizontal ? progressValue : nil,
                height: axis == .vertical ? progressValue : nil
            )
            .offset(
                x: axis == .horizontal ?
                    (progress > 0.5 ? progressValue : -progressValue) / 2 : 0,
                y: axis == .vertical ?
                    (progress < 0.5 ? progressValue : -progressValue) / 2 : 0
            )
    }
}
