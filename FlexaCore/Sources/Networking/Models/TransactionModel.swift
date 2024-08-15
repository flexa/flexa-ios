//
//  TransactionModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/20/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension Models {
    struct Transaction: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case id, asset, amount, label, signature, size
            case statusString = "status"
            case transactionDestination = "destination"
            case transactionFee = "fee"
        }

        var id: String?
        var asset: String?
        var amount: String?
        var label: String?
        var signature: String?
        var size: String?
        var statusString: String?
        var transactionDestination: Models.Destination?
        var transactionFee: Models.Fee?

        init(id: String,
             asset: String,
             amount: String,
             label: String,
             signature: String? = nil,
             size: String,
             statusString: String,
             transactionDestination: Models.Destination,
             transactionFee: Models.Fee
        ) {
            self.id = id
            self.asset = asset
            self.amount = amount
            self.label = label
            self.signature = signature
            self.size = size
            self.statusString = statusString
            self.transactionDestination = transactionDestination
            self.transactionFee = transactionFee
        }
    }
}

extension Models.Transaction: FlexaCore.Transaction {
    var status: TransactionStatus? {
        TransactionStatus(rawValue: statusString ?? "") ?? .unkown
    }

    var destination: Destination? {
        transactionDestination
    }

    var fee: Fee? {
        transactionFee
    }
}
