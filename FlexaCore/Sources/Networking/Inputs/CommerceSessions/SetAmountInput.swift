//
//  SetAmountInput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 3/14/25.
//  Copyright © 2025 Flexa. All rights reserved.
//

import Foundation

struct SetAmountInput: FlexaModelProtocol {
    var preferences: Preferences
    var amount: String

    init(amount: Decimal, paymentAssetId: String) {
        self.amount = amount.apiFormatted
        preferences = Preferences(paymentAsset: paymentAssetId)
    }
}

extension SetAmountInput {
    struct Preferences: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case paymentAsset = "payment_asset"
        }

        var paymentAsset: String
    }
}
