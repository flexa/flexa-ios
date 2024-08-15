//
//  AssetsResource.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import FlexaNetworking
import Factory
import Foundation

enum AssetsResource: FlexaAPIResource, JWTAuthenticable {
    case listAll(limit: Int?, startingAfter: String?)

    var path: String {
        "/assets"
    }

    var queryParams: [String: String]? {
        switch self {
        case .listAll(let limit, let startingAfter):
            return paginationParams(limit: limit, startingAfter: startingAfter)
        }
    }
}
