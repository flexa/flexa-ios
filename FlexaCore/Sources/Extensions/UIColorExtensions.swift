//
//  UIColorExtensions.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/23/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import UIKit

extension UIColor {
    static let systemColors: [String: UIColor] = [
        "black": .black,
        "darkGray": .darkGray,
        "lightGray": .lightGray,
        "white": .white,
        "gray": .gray,
        "red": .red,
        "green": .green,
        "blue": .blue,
        "cyan": .cyan,
        "yellow": .yellow,
        "magenta": .magenta,
        "orange": .orange,
        "purple": .purple,
        "brown": .brown,
        "clear": .clear,
        "systemRed": .systemRed,
        "systemGreen": .systemGreen,
        "systemBlue": .systemBlue,
        "systemOrange": .systemOrange,
        "systemYellow": .systemYellow,
        "systemPink": .systemPink,
        "systemPurple": .systemPurple,
        "systemTeal": .systemTeal,
        "systemIndigo": .systemIndigo,
        "systemBrown": .systemBrown,
        "systemGray": .systemGray,
        "systemGray2": .systemGray2,
        "systemGray3": .systemGray3,
        "systemGray4": .systemGray4,
        "systemGray5": .systemGray5,
        "systemGray6": .systemGray6,
        "label": .label,
        "secondaryLabel": .secondaryLabel,
        "tertiaryLabel": .tertiaryLabel,
        "quaternaryLabel": .quaternaryLabel,
        "link": .link,
        "placeholderText": .placeholderText,
        "separator": .separator,
        "opaqueSeparator": .opaqueSeparator,
        "systemBackground": .systemBackground,
        "secondarySystemBackground": .secondarySystemBackground,
        "tertiarySystemBackground": .tertiarySystemBackground,
        "systemGroupedBackground": .systemGroupedBackground,
        "secondarySystemGroupedBackground": .secondarySystemGroupedBackground,
        "tertiarySystemGroupedBackground": .tertiarySystemGroupedBackground,
        "systemFill": .systemFill,
        "secondarySystemFill": .secondarySystemFill,
        "tertiarySystemFill": .tertiarySystemFill,
        "quaternarySystemFill": .quaternarySystemFill,
        "lightText": .lightText,
        "darkText": .darkText
    ]

    convenience init?(hex: String) {
        // Regular expression to recognize short and long hex values, with and without alpha: #abc, #abcd, #aabbcc, #aabbccdd
        let hexPattern = #"^#?([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{4}|[0-9A-Fa-f]{8})$"#

        guard hex.range(of: hexPattern, options: .regularExpression) != nil else {
            return nil
        }

        var hexValue = hex.replacingOccurrences(of: "#", with: "")

        if hexValue.count == 3 || hexValue.count == 4 {
            // Convert short hex values to long ones
            hexValue = hexValue.reduce("") { "\($0)\($1)\($1)" }
        }

        let scanner = Scanner(string: hexValue)
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)

        let alpha: CGFloat
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat

        // Calculate each color component
        if hexValue.count == 8 {
            alpha = CGFloat((hexNumber & 0xFF000000) >> 24) / 255.0
            red = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255.0
            green = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255.0
            blue = CGFloat(hexNumber & 0x000000FF) / 255.0
        } else {
            alpha = 1.0
            red = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
            green = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(hexNumber & 0x0000FF) / 255.0
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    convenience init?(rgba: String) {
        // swiftlint:disable:next line_length
        let rgbaPattern = #"^rgba\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*((0(\.\d+)?|1(\.0+)?)|\.\d+)\s*\)$"#

        guard let regex = try? NSRegularExpression(pattern: rgbaPattern, options: []),
              let match = regex.firstMatch(in: rgba, options: [], range: NSRange(location: 0, length: rgba.count)),
              let redRange = Range(match.range(at: 1), in: rgba),
              let greenRange = Range(match.range(at: 2), in: rgba),
              let blueRange = Range(match.range(at: 3), in: rgba),
              let alphaRange = Range(match.range(at: 4), in: rgba) else {
            return nil
        }

        let red = CGFloat((rgba[redRange] as NSString).floatValue / 255.0)
        let green = CGFloat((rgba[greenRange] as NSString).floatValue / 255.0)
        let blue = CGFloat((rgba[blueRange] as NSString).floatValue / 255.0)
        let alpha = CGFloat((rgba[alphaRange] as NSString).floatValue)

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    convenience init?(string: String) {
        if let color = UIColor(hex: string) ?? UIColor(rgba: string) ?? Self.systemColors[string] {
            self.init(cgColor: color.cgColor)
        } else {
            return nil
        }
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

    public func shiftingHue(by degrees: CGFloat) -> UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return self
        }

        return UIColor(
            hue: hue + degrees / 360.0,
            saturation: saturation,
            brightness: brightness,
            alpha: alpha)
    }
}
