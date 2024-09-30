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
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self) ?? ""
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
    var asCurrency: String {
        (self as NSDecimalNumber).asCurrency
    }

    func rounded(places: Int) -> Decimal {
        var decimal = self
        var rounded: Decimal = 0
        NSDecimalRound(&rounded, &decimal, places, .down)
        return rounded
    }
}
