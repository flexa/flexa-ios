//
//  ColorExtensions.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/23/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

extension Color {
    public var hex: String {
        UIColor(self).hex
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
