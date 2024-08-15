//
//  AssetModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import SwiftUI

extension Models {
    struct Asset: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case id, symbol, livemode
            case colorString = "color"
            case iconUrl = "icon_url"
            case displayName = "display_name"
        }

        var id: String
        var symbol: String
        var colorString: String?
        var iconUrl: URL?
        var displayName: String
        var livemode: Bool

        var color: Color? {
            guard let colorString else {
                return nil
            }
            return Color(hex: colorString)
        }
    }
}

extension Models.Asset: Asset {
}
