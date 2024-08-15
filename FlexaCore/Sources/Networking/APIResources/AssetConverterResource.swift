//
//  AssetConverterResource.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/12/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import FlexaNetworking
import Foundation

enum AssetConverterResource: FlexaAPIResource, JWTAuthenticable {
    case convert(ConvertAssetInput)

    var path: String {
        "/asset_converter"
    }

    var method: RequestMethod {
        .put
    }

    var bodyParams: [String: Any]? {
        switch self {
        case .convert(let input):
            return input.dictionary
        }
    }
}
