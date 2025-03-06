//
//  NumberExtensions.swift
//
//  Created by Rodrigo Ordeix on 5/20/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public extension Decimal {
    var apiFormatted: String {
        Decimal(string: self.description, locale: Locale(identifier: "en_US"))?.description ?? ""
    }
}

public extension NSNumber {
    var asCurrency: String {
        asCurrency()
    }

    func asCurrency(usesGroupingSeparator: Bool = false,
                    locale: Locale = Locale(identifier: "en-US"),
                    minimumFractionDigits: Int = 2,
                    maximumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = usesGroupingSeparator
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: self as NSNumber) ?? ""
    }
}

public extension Double {
    var asCurrency: String {
        NSNumber(value: self).asCurrency
    }
}

public extension Float {
    var asCurrency: String {
        NSNumber(value: self).asCurrency
    }
}

public extension Decimal {
    private var nsNumber: NSNumber {
        NSDecimalNumber(decimal: self)
    }

    func rounded(places: Int) -> Decimal {
        var decimal = self
        var rounded: Decimal = 0
        NSDecimalRound(&rounded, &decimal, places, .down)
        return rounded
    }

    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }

    var asCurrency: String {
        asCurrency()
    }

    func asCurrency(usesGroupingSeparator: Bool = false,
                    locale: Locale = Locale(identifier: "en-US"),
                    minimumFractionDigits: Int = 2,
                    maximumFractionDigits: Int = 2) -> String {
        nsNumber.asCurrency(
            usesGroupingSeparator: usesGroupingSeparator,
            locale: locale,
            minimumFractionDigits: minimumFractionDigits,
            maximumFractionDigits: maximumFractionDigits
        )
    }

    func formatted(usesGroupingSeparator: Bool = false,
                   locale: Locale = Locale(identifier: "en-US"),
                   minimumFractionDigits: Int = 0,
                   maximumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = usesGroupingSeparator
        formatter.locale = locale
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: self as NSNumber) ?? ""
    }
}
