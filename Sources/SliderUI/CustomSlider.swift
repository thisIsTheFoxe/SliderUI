//
//  CustomSlider.swift
//  Created by Henry on 27/05/24.
//

import SwiftUI

public struct CustomSlider<S: Shape>: View {
    // MARK: - Properties
    @Binding private var sliderProgress: CGFloat
    private let config: SliderConfiguration
    private let constants: SliderConstants
    private let clipShape: S
    
    // MARK: - State
    @State private var progress: CGFloat
    @State private var dragOffset: CGFloat = .zero
    @State private var lastDragOffset: CGFloat = .zero
    @State private var isDragging = false
    
    // MARK: - Initialization
    public init(sliderProgress: Binding<CGFloat>,
                configuration: SliderConfiguration = .init(),
                constants: SliderConstants = .init(),
                clipShape: S = .capsule) {
        self._sliderProgress = sliderProgress
        self.progress = sliderProgress.wrappedValue
        self.config = configuration
        self.constants = constants
        self.clipShape = clipShape
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let orientationSize = config.axis == .horizontal ? size.width : size.height
            let progressValue = calculateProgressValue(orientationSize: orientationSize)
            
            mainSliderContent(size: size, orientationSize: orientationSize, progressValue: progressValue)
                .onChange(of: sliderProgress) {
                    sliderProgressChanged(orientationSize: orientationSize)
                }
                .onChange(of: config.axis, initial: true) {
                    updateDragOffsets(orientationSize: orientationSize)
                }
        }
        .onChange(of: progress, progressChanged)
    }
    
    // MARK: - Private Views
    @ViewBuilder
    private func mainSliderContent(size: CGSize, orientationSize: CGFloat, progressValue: CGFloat) -> some View {
        ZStack(alignment: sliderAlignment) {
            backgroundLayer
            sliderFillLayer(orientationSize: orientationSize, progressValue: progressValue)
            symbolLayer
        }
        .clipShape(AnyShape(clipShape))
        .modifier(SliderFrameModifier(
            isDragging: isDragging,
            alwaysVisible: config.alwaysVisible,
            compactSize: constants.compactSize,
            axis: config.axis
        ))
        .contentShape(dragArea(size: size))
        .frame(
            width: stretchyWidth(for: size.width),
            height: stretchyHeight(for: size.height)
        )
        .scaleEffect(scaleEffect.0, anchor: scaleEffect.1)
        .gesture(dragGesture(orientationSize: orientationSize))
        .frame(
            width: size.width,
            height: size.height,
            alignment: frameAlignment
        )
    }
    
    private var backgroundLayer: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
    }
    
    @ViewBuilder
    private func sliderFillLayer(orientationSize: CGFloat, progressValue: CGFloat) -> some View {
        switch config.type {
        case .basic:
            Rectangle()
                .fill(config.tint)
                .frame(
                    width: config.axis == .horizontal ? progressValue : nil,
                    height: config.axis == .vertical ? progressValue : nil
                )
        case .centered:
            CenteredSliderFill(
                orientationSize: orientationSize,
                progressValue: progressValue,
                progress: progress,
                axis: config.axis,
                tint: config.tint
            )
        }
    }
    
    @ViewBuilder
    private var symbolLayer: some View {
        if let symbol = config.symbol {
            Image(systemName: symbol)
                .foregroundStyle(config.symbolColor)
                .padding()
                .opacity(isDragging ? 1 : 0)
                .frame(width: isDragging ? nil : 0,
                       height: isDragging ? nil : 0)
        }
    }
    
    // MARK: - Computed Properties
    private var sliderAlignment: Alignment {
        config.type == .centered ? .center :
            (config.axis == .horizontal ? .leading : .bottom)
    }
    
    private var frameAlignment: Alignment {
        if config.axis == .vertical {
            return progress < 0 ? .top : .bottom
        } else {
            return progress < 0 ? .trailing : .leading
        }
    }
    
    var scaleEffect: (CGSize, UnitPoint) {
        let scale = calculateScaleEffect()
        return config.axis == .horizontal ?
            (CGSize(width: 1, height: scale), (progress < 0 ? .trailing : .leading)) :
            (CGSize(width: scale, height: 1), (progress < 0 ? .top : .bottom))
    }
    
    // MARK: - Helper Methods
    private func calculateScaleEffect() -> CGFloat {
        let topAndTrailingScale = 1 - (progress - 1) * constants.scalieness
        let bottomAndLeadingScale = 1 + progress * constants.scalieness
        return progress > 1 ? topAndTrailingScale :
            (progress < 0 ? bottomAndLeadingScale : 1)
    }
    
    private func calculateProgressValue(orientationSize: CGFloat) -> CGFloat {
        if config.type == .centered {
            return progress < 0.5 ?
                (0.5 - progress) * orientationSize :
                (progress - 0.5) * orientationSize
        } else {
            return max(progress, .zero) * orientationSize
        }
    }
    
    private func stretchyWidth(for width: CGFloat) -> CGFloat? {
        config.axis == .horizontal ? strechyValue(for: width) : nil
    }
    
    private func stretchyHeight(for height: CGFloat) -> CGFloat? {
        config.axis == .vertical ? strechyValue(for: height) : nil
    }
    
    private func strechyValue(for orientationSize: CGFloat) -> CGFloat? {
        if progress < 0 { return orientationSize + (-progress * orientationSize) }
        else if progress > 1 { return progress * orientationSize }
        else { return nil }
    }
    
    private func dragArea(size: CGSize) -> some Shape {
        Rectangle()
            .size(
                width: size.width * constants.widthScale,
                height: size.height * constants.heightScale
            )
            .offset(
                x: (size.width - size.width * constants.widthScale) / 2,
                y: (size.height - size.height * constants.heightScale) / 2
            )
    }
    
    private func calculateProgress(orientationSize: CGFloat) {
        let topAndTrailingExcessOffset = orientationSize +
            (dragOffset - orientationSize) * constants.stretchiness
        let bottomAndLeadingExcessOffset = dragOffset < 0 ?
            (dragOffset * constants.stretchiness) : dragOffset
        
        let rawProgress = (dragOffset > orientationSize ?
                          topAndTrailingExcessOffset : bottomAndLeadingExcessOffset) / orientationSize
        
        progress = rawProgress < 0 ?
            (-rawProgress > constants.limitation ? -constants.limitation : rawProgress) :
            (rawProgress > (1.0 + constants.limitation) ? (1.0 + constants.limitation) : rawProgress)
    }
    
    // MARK: - Event Handlers
    private func sliderProgressChanged(orientationSize: CGFloat) {
        guard sliderProgress != progress,
              (sliderProgress > 0 && sliderProgress < 1) else { return }
        progress = max(min(sliderProgress, 1.0), 0)
        updateDragOffsets(orientationSize: orientationSize)
    }
    
    private func updateDragOffsets(orientationSize: CGFloat) {
        dragOffset = progress * orientationSize
        lastDragOffset = dragOffset
    }
    
    private func progressChanged() {
        sliderProgress = max(min(progress, 1.0), 0.0)
    }
    
    private func dragGesture(orientationSize: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                handleDragChange(gesture: gesture)
                calculateProgress(orientationSize: orientationSize)
            }
            .onEnded { _ in
                handleDragEnd(orientationSize: orientationSize)
            }
    }
    
    private func handleDragChange(gesture: DragGesture.Value) {
        if !isDragging {
            withAnimation {
                isDragging = true
            }
        }
        
        let translation = gesture.translation
        let movement = (config.axis == .horizontal ?
                       translation.width : -translation.height) + lastDragOffset
        dragOffset = movement
    }
    
    private func handleDragEnd(orientationSize: CGFloat) {
        withAnimation(.smooth) {
            dragOffset = dragOffset > orientationSize ?
                orientationSize : (dragOffset < 0 ? 0 : dragOffset)
            calculateProgress(orientationSize: orientationSize)
        }
        lastDragOffset = dragOffset
        
        withAnimation(.default.delay(1.25)) {
            isDragging = false
        }
    }
}

#Preview {
    VStack {
        Spacer()
        
        CustomSlider(sliderProgress: State(initialValue: 0.5).projectedValue,
                     configuration: .init(symbol: "circle.fill",
                                          axis: .vertical,
                                          type: .centered),
                     clipShape: .rect(cornerRadius: 20))
        .frame(width: 100, height: 250)
        .background(Color.blue)
        
        Spacer()
    }
    .preferredColorScheme(.dark)
}


