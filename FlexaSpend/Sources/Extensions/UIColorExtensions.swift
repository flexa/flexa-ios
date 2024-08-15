//
//  UIColorExtensions.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 12/15/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init?(hex: String) {
        let offset = hex.hasPrefix("#") ? 1 : 0
        let start = hex.index(hex.startIndex, offsetBy: offset)
        let hexColor = String(hex[start...])
        let scanner = Foundation.Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        guard scanner.scanHexInt64(&hexNumber) else {
            return nil
        }

        self.init(
            red: CGFloat((hexNumber & 0xff0000) >> 16) / 255,
            green: CGFloat((hexNumber & 0x00ff00) >> 8) / 255,
            blue: CGFloat((hexNumber & 0x0000ff)) / 255,
            alpha: 1
        )
    }

    var hex: String {
        let red: Int = (Int)(rgba.red * 255) << 16
        let green: Int = (Int)(rgba.green * 255) << 8
        let blue: Int = (Int)(rgba.blue * 255) << 0
        let rgb = red | green | blue

        return String(format: "#%06x", rgb)
    }

    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}

// MARK: Array<UIColor>
extension Array where Element == UIColor {
    var hex: [String] {
        map { $0.hex }
    }
}
