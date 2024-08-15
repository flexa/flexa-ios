//
//  AppAccountsResource.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import FlexaNetworking
import Factory
import Foundation

enum CommerceSessionResource: FlexaAPIResource, JWTAuthenticable {
    case watch([String])
    case create(CreateCommerceSessionInput)
    case setPaymentAsset(String, SetPaymentAssetInput)
    case close(String)

    private static let idUrlParameter = ":id"

    var method: RequestMethod {
        switch self {
        case .watch:
            return .get
        case .setPaymentAsset:
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
            return "/commerce_sessions"
        case .close, .setPaymentAsset:
            return "/commerce_sessions/\(Self.idUrlParameter)"
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
        case .watch, .close:
            return nil
        case .create(let input):
            return input.dictionary
        case .setPaymentAsset(_, let input):
            return input.dictionary
        }
    }

    var pathParams: [String: String]? {
        switch self {
        case .close(let id), .setPaymentAsset(let id, _):
            return [Self.idUrlParameter: id]
        default:
            return nil
        }
    }
}
