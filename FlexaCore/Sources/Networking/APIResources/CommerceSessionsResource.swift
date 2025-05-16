//
//  CommerceSessionResource.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import FlexaNetworking
import Factory
import Foundation

enum CommerceSessionResource: FlexaAPIResource, JWTAuthenticable {
    case create(CreateCommerceSessionInput)
    case get(String)
    case watch([String])
    case setPaymentAsset(String, SetPaymentAssetInput)
    case setAmount(String, SetAmountInput)
    case close(String)
    case approve(String)

    private static let idUrlParameter = ":id"
    private static let resourcePath = "/commerce_sessions"

    var method: RequestMethod {
        switch self {
        case .watch, .get:
            return .get
        case .setPaymentAsset, .setAmount:
            return .patch
        default:
            return .post
        }
    }

    var headers: [String: String]? {
        switch self {
        case .watch:
            return [
                "Accept": "text/event-stream",
                "Cache-Control": "no-cache",
                "Connection": "keep-alive"
            ]
        default:
            return nil
        }
    }

    var path: String {
        switch self {
        case .watch:
            return "/events"
        case .create:
            return Self.resourcePath
        case .setPaymentAsset, .get, .setAmount:
            return "\(Self.resourcePath)/\(Self.idUrlParameter)"
        case .close:
            return "\(Self.resourcePath)/\(Self.idUrlParameter)/close"
        case .approve:
            return "\(Self.resourcePath)/\(Self.idUrlParameter)/approve"
        }
    }

    var queryParams: [String: String]? {
        switch self {
        case .watch(let events):
            guard !events.isEmpty else {
                return nil
            }
            return ["type": events.joined(separator: ",")]
        default:
            return nil
        }
    }

    var bodyParams: [String: Any]? {
        switch self {
        case .watch, .close, .get, .approve:
            return nil
        case .create(let input):
            return input.dictionary
        case .setPaymentAsset(_, let input):
            return input.dictionary
        case .setAmount(_, let input):
            return input.dictionary
        }
    }

    var pathParams: [String: String]? {
        switch self {
        case .close(let id), .setPaymentAsset(let id, _), .get(let id), .approve(let id), .setAmount(let id, _):
            return [Self.idUrlParameter: id]
        default:
            return nil
        }
    }

    func wrappingError(_ error: Error?, traceId: String?) -> Error? {
        switch self {
        case .create:
            ReasonableError(reason: .cannotCreateCommerceSession(error))
        case .get:
            ReasonableError(reason: .cannotGetCommerceSession(error))
        case .watch:
            ReasonableError(reason: .cannotWatchSession(error))
        case .close:
            ReasonableError(reason: .cannotCloseCommerceSession(error))
        case .approve:
            ReasonableError(reason: .cannotApproveCommerceSession(error))
        case .setPaymentAsset:
            ReasonableError(reason: .cannotSetCommerceSessionPaymentAsset(error))
        case .setAmount:
            ReasonableError(reason: .cannotSetCommerceSessionAmount(error))
        }
    }
}
