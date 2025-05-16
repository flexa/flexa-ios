//
//  ColorExtensions.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/23/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI
import Factory

extension Color {
    public var hex: String {
        UIColor(self).hex
    }

    public var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        UIColor(self).rgba
    }

    public var luminance: Double {
        let components = rgba
        return 0.2126 * components.red + 0.7152 * components.green + 0.0722 * components.green
    }

    public var isDark: Bool {
        luminance < 0.5
    }

    public init(hex: String) {
        guard let uiColor = UIColor(hex: hex) else {
            self.init(UIColor.clear)
            return
        }
        self.init(uiColor)
    }

    public init(lightColor: UIColor? = nil, darkColor: UIColor? = nil) {
        self.init(
            UIColor(dynamicProvider: { traitCollection in
                if traitCollection.userInterfaceStyle == .light {
                    return lightColor ?? darkColor ?? .clear
                } else if traitCollection.userInterfaceStyle == .dark {
                    return darkColor ?? lightColor ?? .clear
                }
                return lightColor ?? .clear
            })
        )
    }

    public func shiftingHue(by degrees: CGFloat) -> Color {
        Color(
            UIColor(self)
                .shiftingHue(by: degrees)
        )
    }
}

public extension Color {
    static var flexaTintColor: Color {
        Container.shared.flexaClient().theme.tintColor
    }

    static var flexaContrastTintColor: Color {
        flexaTintColor.isDark ? .white : .black
    }
}
