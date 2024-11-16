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

        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: CodingKeys.id)
            self.livemode = try container.decode(Bool.self, forKey: CodingKeys.livemode)
            self.label = try container.decode(String.self, forKey: CodingKeys.label)
            self.asset = try container.decode(String.self, forKey: CodingKeys.asset)
            self.amountOffString = try container.decodeIfPresent(String.self, forKey: CodingKeys.amountOffString)
            self.percentOffString = try container.decodeIfPresent(String.self, forKey: CodingKeys.percentOffString)
            self.promotionRestrictions = try container.decode(Restriction.self, forKey: CodingKeys.promotionRestrictions)

            if let urlString = try container.decodeIfPresent(String.self, forKey: CodingKeys.url), !urlString.isEmpty {
                self.url = URL(string: urlString)
            } else {
                self.url = nil
            }
        }
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
