//
//  BrandModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import SwiftUI

extension Models {
    struct Brand: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case id, name, slug
            case colorString = "color"
            case logoUrl = "logo_url"
            case brandLegacyFlexcodes = "legacy_flexcodes"
        }

        var id: String
        var colorString: String?
        var logoUrl: URL?
        var name: String
        var slug: String
        var brandLegacyFlexcodes: [LegacyFlexcode]?

        var color: Color? {
            guard let colorString else {
                return nil
            }
            return Color(hex: colorString)
        }

        init(id: String,
             colorString: String? = nil,
             logoUrl: URL? = nil,
             name: String,
             slug: String,
             legacyFlexcodes: [LegacyFlexcode]? = nil) {
            self.id = id
            self.colorString = colorString
            self.logoUrl = logoUrl
            self.name = name
            self.slug = slug
            self.brandLegacyFlexcodes = legacyFlexcodes
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.name = try container.decode(String.self, forKey: .name)
            self.slug = try container.decode(String.self, forKey: .slug)
            self.colorString = try container.decodeIfPresent(String.self, forKey: .colorString)
            self.logoUrl = try container.decodeIfPresent(URL.self, forKey: .logoUrl)
            self.brandLegacyFlexcodes = try container.decodeIfPresent([Models.Brand.LegacyFlexcode].self, forKey: .brandLegacyFlexcodes)
        }
    }
}

extension Models.Brand: Brand {
    var legacyFlexcodes: [BrandLegacyFlexcode]? {
        brandLegacyFlexcodes
    }
}

extension Models.Brand {
    struct LegacyFlexcode: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case asset
            case legacyFlexcodeAmount = "amount"
        }

        var asset: String
        var legacyFlexcodeAmount: Amount?
    }
}

extension Models.Brand.LegacyFlexcode: BrandLegacyFlexcode {
    var amount: BrandLegacyFlexcodeAmount? {
        legacyFlexcodeAmount
    }
}

extension Models.Brand.LegacyFlexcode {
    struct Amount: FlexaModelProtocol {
        var maximum: String?
        var minimum: String?
    }
}

extension Models.Brand.LegacyFlexcode.Amount: BrandLegacyFlexcodeAmount {
    var min: String? {
        minimum
    }

    var max: String? {
        maximum
    }
}
