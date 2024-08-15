//
//  CircularGradientView.swift
//  FlexaUICore
//
//  Created by Rodrigo Ordeix on 8/30/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI

public struct CircularGradientView: View {
    var gradientColors: [Color]
    var size: CGFloat

    public init(gradientColors: [Color], size: CGFloat) {
        self.gradientColors = gradientColors
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: size, height: size)
        }
    }
}
