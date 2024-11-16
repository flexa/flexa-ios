//
//  SpendCircleImage.swift
//  FlexaUICore
//
//  Created by Rodrigo Ordeix on 8/30/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI
import FlexaCore

public struct SpendCircleImage: View {
    var image: Image?
    var url: URL?
    let size: CGFloat
    let gradientColors: [Color]
    let placeholderColor: Color

    public init(
        _ image: Image,
        size: CGFloat = 24,
        gradientColors: [Color] = [],
        placeholderColor: Color = .primary.opacity(0.2)
    ) {
        self.image = image
        self.size = size
        self.gradientColors = gradientColors
        self.placeholderColor = placeholderColor
    }

    public init(
        _ url: URL?,
        size: CGFloat = 24,
        gradientColors: [Color] = [],
        placeholderColor: Color = .primary.opacity(0.2)
    ) {
        self.url = url
        self.size = size
        self.gradientColors = gradientColors
        self.placeholderColor = placeholderColor
    }

    public var body: some View {
        if let image {
            image.resizable()
                .clipShape(Circle())
                .aspectRatio(contentMode: .fill)
                .scaledToFill()
                .frame(width: size, height: size)
        } else if let url {
            RemoteImageView(
                url: url,
                content: { image in
                    image.resizable()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                        .aspectRatio(contentMode: .fill)
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .background(
                            CircularGradientView(gradientColors: gradientColors, size: size)
                        )
                },
                placeholder: {
                    CircularGradientView(gradientColors: [placeholderColor], size: size)
                })
        } else {
            CircularGradientView(gradientColors: [placeholderColor], size: size)
        }
    }
}
