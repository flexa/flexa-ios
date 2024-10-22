//
//  PromotionModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/16/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension Models {
    struct Promotion: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case id, livemode, label, asset, url
            case amountOffString = "amount_off"
            case percentOffString = "percent_off"
            case promotionRestrictions = "restrictions"
        }

        let id: String
        let livemode: Bool
        let label: String
        let asset: String
        let url: URL?

        private let amountOffString: String?
        private let percentOffString: String?
        private let promotionRestrictions: Restriction
    }
}

extension Models.Promotion {
    struct Restriction: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case maximumDiscountString = "maximum_discount"
            case minimumAmountString = "minimum_amount"
        }

        private var maximumDiscountString: String?
        private var minimumAmountString: String?
    }
}

extension Models.Promotion.Restriction: PromotionRestriction {
    var maximumDiscount: Decimal? {
        maximumDiscountString?.decimalValue
    }

    var minimumAmount: Decimal? {
        minimumAmountString?.decimalValue
    }
}

extension Models.Promotion: Promotion {
    var amountOff: Decimal? {
        amountOffString?.decimalValue
    }

    var percentOff: Decimal? {
        percentOffString?.decimalValue
    }

    var restrictions: PromotionRestriction? {
        promotionRestrictions
    }
}
