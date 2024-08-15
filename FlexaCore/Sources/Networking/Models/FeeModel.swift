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
            case asset, label, amount, equivalent
            case feePrice = "price"
        }

        var amount: String
        var asset: String
        var equivalent: String
        var label: String
        var feePrice: Models.Price
    }
}

extension Models.Fee: Fee {
    var price: Price {
        feePrice
    }
}
