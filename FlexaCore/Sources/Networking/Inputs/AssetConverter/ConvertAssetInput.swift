//
//  ConvertAssetInput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/12/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

struct ConvertAssetInput: FlexaModelProtocol {
    enum CodingKeys: String, CodingKey {
        case amount, asset
        case unitOfAccount = "unit_of_account"
    }

    var amount: String
    var asset: String
    var unitOfAccount: String

    init(amount: Decimal, asset: String, unitOfAccount: String) {
        self.asset = asset
        self.unitOfAccount = unitOfAccount
        self.amount = amount.apiFormatted
    }
}
