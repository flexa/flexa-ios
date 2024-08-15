//
//  Shadow.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 22/2/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

public extension FXTheme.Shadow {
    enum CodingKeys: String, CodingKey {
        case x, y, radius
        case colorName = "color"
    }

}

public extension FXTheme {
    struct Shadow: FlexaThemable {
        public static let `default`: Shadow = Shadow(radius: 0)
        private let defaultColor = Color.black.opacity(0.33)

        public var x, y, radius: CGFloat
        public var colorName: String?

        public var color: Color {
            colorBy(name: colorName, fallbackColor: defaultColor)
        }

        public init(x: CGFloat = 0, y: CGFloat = 0, radius: CGFloat, colorName: String? = nil) {
            self.x = x
            self.y = y
            self.radius = radius
            self.colorName = colorName
        }
    }
}
