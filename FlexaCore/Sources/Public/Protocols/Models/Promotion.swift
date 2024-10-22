//
//  Promotion.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/16/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol Promotion {
    var id: String { get }
    var livemode: Bool { get }
    var label: String { get }
    var asset: String { get }

    var amountOff: Decimal? { get }
    var percentOff: Decimal? { get }
    var url: URL? { get }
    var restrictions: PromotionRestriction? { get }
}

public protocol PromotionRestriction {
    var maximumDiscount: Decimal? { get }
    var minimumAmount: Decimal? { get }
}

public extension Promotion {
    func appliesTo(amount: Decimal, asset: String = FlexaConstants.usdAssetId) -> Bool {
        guard amount > 0 else {
            return false
        }

        guard let minimumAmount = restrictions?.minimumAmount else {
            return true
        }
        return minimumAmount <= amount
    }

    func discount(for amount: Decimal, asset: String = FlexaConstants.usdAssetId) -> Decimal {
        guard appliesTo(amount: amount, asset: asset) else {
            return 0
        }
        var discount: Decimal = 0

        if let amountOff {
            discount = min(amountOff, amount)
        } else if let percentOff {
            discount = min(amount * percentOff / 100, amount)
        }
        return min(discount, restrictions?.maximumDiscount ?? amount)
    }
}

public extension Array where Element == Promotion {
    func applyingTo(amount: Decimal, asset: String = FlexaConstants.usdAssetId) -> [Promotion] {
        filter { $0.appliesTo(amount: amount, asset: asset) }
    }
}
