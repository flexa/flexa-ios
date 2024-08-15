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

    public init(_ image: Image, size: CGFloat = 24, gradientColors: [Color] = []) {
        self.image = image
        self.size = size
        self.gradientColors = gradientColors
    }

    public init(_ url: URL?, size: CGFloat = 24, gradientColors: [Color] = []) {
        self.url = url
        self.size = size
        self.gradientColors = gradientColors
    }

    public var body: some View {
        if let image {
            image.resizable()
                .clipShape(Circle())
                .aspectRatio(contentMode: .fill)
                .overlay(Circle().stroke(Color.gray, lineWidth: 4))
                .shadow(radius: 1)
                .scaledToFit()
                .frame(width: size, height: size)
        } else if let url {
            RemoteImageView(
                url: url,
                content: { image in
                    image.resizable()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                        .aspectRatio(contentMode: .fill)
                        .shadow(radius: 1)
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .background(
                            CircularGradientView(gradientColors: gradientColors, size: size)
                        )
                },
                placeholder: {
                    CircularGradientView(gradientColors: [.primary.opacity(0.2)], size: size)
                })
        } else {
            CircularGradientView(gradientColors: [.primary.opacity(0.2)], size: size)
        }
    }
}

public struct SpendCircleImage_Previews: PreviewProvider {
    public static var previews: some View {
        SpendCircleImage(Image(systemName: "person.badge.shield.checkmark.fill"))
    }
}
