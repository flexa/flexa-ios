//
//  PriceModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/20/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension Models {
    struct Price: FlexaModelProtocol {
        var amount: String
        var label: String
        var priority: String?

        init(amount: String, label: String, priority: String) {
            self.amount = amount
            self.label = label
            self.priority = priority
        }
    }
}

extension Models.Price: Price {
}
