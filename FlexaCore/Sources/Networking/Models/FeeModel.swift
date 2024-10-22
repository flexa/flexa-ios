//
//  FeeModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/20/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension Models {
    struct Fee: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case asset, amount
            case feePrice = "price"
            case transactionAsset = "transaction_asset"
        }

        var amount: String
        var asset: String
        var feePrice: Models.Price?
        var zone: String?
        var transactionAsset: String?
    }
}

extension Models.Fee: Fee {
    var price: Price? {
        feePrice
    }
}
