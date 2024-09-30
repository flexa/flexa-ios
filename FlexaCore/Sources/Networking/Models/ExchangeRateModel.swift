//
//  ExchangeRateModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 9/29/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension Models {
    struct ExchangeRate: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case asset, label, precision, price
            case expiresAt = "expires_at"
            case unitOfAccount = "unit_of_account"
        }

        var asset: String
        var expiresAt: Int
        var label: String
        var precision: Int
        var price: String
        var unitOfAccount: String
    }
}

extension Models.ExchangeRate: ExchangeRate {
    var decimalPrice: Decimal {
        price.decimalValue ?? 0
    }

    var isExpired: Bool {
        Date().timeIntervalSince1970 >= Double(expiresAt)
    }
}
