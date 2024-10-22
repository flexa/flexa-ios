//
//  TransactionFeesResource.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import FlexaNetworking
import Foundation

enum TransactionFeesResource: FlexaAPIResource, JWTAuthenticable {
    case get(assets: [String], limit: Int?, startingAfter: String?)

    var path: String {
        "/transaction_fees"
    }

    var method: RequestMethod {
        .get
    }

    var queryParams: [String: String]? {
        switch self {
        case .get(let assets, let limit, let startingAfter):
            return [
                "transaction_assets": assets.joined(separator: ",")
            ].merging(
                paginationParams(limit: limit, startingAfter: startingAfter)
            ) { (current, _) in
                current
            }
        }
    }

    func wrappingError(_ error: Error?, traceId: String?) -> Error? {
        ReasonableError(reason: .cannotGetExchangeRates(error))
    }
}
