//
//  TransactionsResource.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/11/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import FlexaNetworking

enum TransactionsResource: FlexaAPIResource, JWTAuthenticable {
    private static let idUrlParameter = ":id"

    case sign(id: String, signature: String)

    var path: String {
        "/transactions/\(Self.idUrlParameter)"
    }

    var method: RequestMethod {
        .patch
    }

    var pathParams: [String: String]? {
        switch self {
        case .sign(let id, _):
            return [Self.idUrlParameter: id]
        }
    }

    var bodyParams: [String: Any]? {
        switch self {
        case .sign(_, let signature):
            return ["signature": signature]
        }
    }

    func wrappingError(_ error: Error?, traceId: String?) -> Error? {
        ReasonableError(reason: .cannotSignTransaction(error))
    }
}
