//
//  ConvertedAsset.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/12/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension Models {
    struct ConvertedAsset: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case amount, label
            case unitOfAccount = "unit_of_account"
            case exchangeRateFee = "fee"
            case exchangeRateValue = "value"
        }

        var unitOfAccount: String
        var exchangeRateFee: Fee
        var exchangeRateValue: Value
        var amount: String
        var label: String
    }
}

extension Models.ConvertedAsset {
    struct Value: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case amount, label
            case valueRate = "rate"
        }

        var valueRate: Models.Rate
        var amount: String
        var label: String
    }
}

extension Models.ConvertedAsset: ConvertedAsset {
    var fee: any Fee {
        exchangeRateFee
    }

    var value: ConvertedAssetValue {
        exchangeRateValue
    }
}

extension Models.ConvertedAsset.Value: ConvertedAssetValue {
    var rate: Rate {
        valueRate
    }
}
