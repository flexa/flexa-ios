//
//  CreateCommerceSessionInput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

struct CreateCommerceSessionInput: FlexaModelProtocol {
    var brand: String
    var amount: String
    var asset: String
    var preferences: Preference

    init(brand: String, amount: Decimal, asset: String, preferences: Preference) {
        self.brand = brand
        self.amount = amount.apiFormatted
        self.asset = asset
        self.preferences = preferences
    }

     init(brand: String, amount: Decimal, asset: String, paymentAsset: String) {
         self.brand = brand
         self.amount = amount.apiFormatted
         self.asset = asset
         self.preferences = Preference(paymentAsset: paymentAsset)
    }
}

extension CreateCommerceSessionInput {
    struct Preference: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case paymentAsset = "payment_asset"
        }

        var paymentAsset: String
    }
}
