//
//  CreatePaymentAssetInput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 8/5/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

struct SetPaymentAssetInput: FlexaModelProtocol {
    var preferences: Preferences

    init(paymentAssetId: String) {
        preferences = Preferences(paymentAsset: paymentAssetId)
    }
}

extension SetPaymentAssetInput {
    struct Preferences: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case paymentAsset = "payment_asset"
        }

        var paymentAsset: String
    }
}
