//
//  BrandsResource.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import FlexaNetworking
import Factory
import Foundation

enum BrandsResource: FlexaAPIResource, JWTAuthenticable {
    case listAll(limit: Int?, startingAfter: String?)
    case listLegacy(limit: Int?, startingAfter: String?)

    var path: String {
        "/brands"
    }

    var queryParams: [String: String]? {
        switch self {
        case .listAll(let limit, let startingAfter):
            return paginationParams(limit: limit, startingAfter: startingAfter)
        case .listLegacy(let limit, let startingAfter):
            return paginationParams(limit: limit, startingAfter: startingAfter, query: "-legacy_flexcodes:null")
        }
    }
}
