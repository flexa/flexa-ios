//
//  CircularProgressView.swift
//  FlexaUICore
//
//  Created by Rodrigo Ordeix on 5/26/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

public struct CircularProgressView<Content: View>: View {
    let progress: Double
    let backgroundRingStrokeColor: Color
    let progressRingStrokeColor: Color
    let strokeWidth: CGFloat
    let trimming: CGFloat
    let animationDuration: TimeInterval
    let warningProgress: Double
    let warningColor: Color
    let content: () -> Content

    private var color: Color {
        progress >= warningProgress ? warningColor : progressRingStrokeColor
    }

    private var calculatedProgress: Double {
        trimming + progress * max(0.5, 1 - 2 * trimming)
    }

    public static func gauge(
        progress: Double,
        strokeWidth: CGFloat = 6,
        progressRingStrokeColor: Color = .purple,
        trimming: Double = 0.15,
        @ViewBuilder content: @escaping () -> Content) -> Self {
            CircularProgressView(
                progress: progress,
                strokeWidth: strokeWidth,
                trimming: trimming,
                progressRingStrokeColor: progressRingStrokeColor,
                animationDuration: 0,
                warningProgress: 1,
                warningColor: progressRingStrokeColor,
                content: content
            )
        }

    public init(progress: Double,
                strokeWidth: CGFloat = 4,
                trimming: CGFloat = 0,
                backgroundRingStrokeColor: Color = .black.opacity(0.1),
                progressRingStrokeColor: Color = .purple,
                animationDuration: TimeInterval = 1,
                warningProgress: Double = 0.75,
                warningColor: Color = .red,
                @ViewBuilder content: @escaping () -> Content) {
        self.progress = progress
        self.strokeWidth = strokeWidth
        self.trimming = trimming
        self.backgroundRingStrokeColor = backgroundRingStrokeColor
        self.progressRingStrokeColor = progressRingStrokeColor
        self.animationDuration = animationDuration
        self.warningProgress = warningProgress
        self.warningColor = warningColor
        self.content = content
    }

    public var body: some View {
        ZStack {
            Circle()
                .trim(from: trimming, to: 1 - trimming)
                .stroke(
                    backgroundRingStrokeColor,
                    style: StrokeStyle(
                        lineWidth: strokeWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(90))

            Circle()
                .trim(from: trimming, to: calculatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: strokeWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(90))
                .animation(.linear(duration: animationDuration), value: progress)
            content()
        }
    }
}
