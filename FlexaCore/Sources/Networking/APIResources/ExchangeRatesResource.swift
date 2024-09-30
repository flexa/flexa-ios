//
//  ExchangeRatesResource.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 9/27/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import FlexaNetworking
import Foundation

enum ExchangeRatesResource: FlexaAPIResource, JWTAuthenticable {
    case get(assets: [String], unitOfAccount: String, limit: Int?, startingAfter: String?)

    var path: String {
        "/exchange_rates"
    }

    var method: RequestMethod {
        .get
    }

    var queryParams: [String: String]? {
        switch self {
        case .get(let assets, let unitOfAccount, let limit, let startingAfter):
            return [
                "assets": assets.joined(separator: ","),
                "unit_of_account": unitOfAccount
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
