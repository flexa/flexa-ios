//
//  CreateCommerceSessionInput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

struct CreateCommerceSessionInput: FlexaModelProtocol {
    var brand: String?
    var amount: String?
    var asset: String?
    var preferences: Preference?
    var paymentLink: URL?

    enum CodingKeys: String, CodingKey {
        case brand, amount, asset, preferences
        case paymentLink = "from_link"
    }

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

    init(paymentLink: URL?, paymentAsset: String) {
        self.paymentLink = paymentLink
        self.preferences = Preference(paymentAsset: paymentAsset)
    }

    var dictionary: [String: Any]? {
        do {
            return (try JSONSerialization.jsonObject(with: jsonData()) as? [String: Any?])?.compactMapValues { $0 }
        } catch let error {
            FlexaLogger.error(error)
        }
        return nil
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
