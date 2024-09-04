//
//  TokensResource.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import FlexaNetworking
import Factory
import Foundation
import UIKit

enum TokensResource: FlexaAPIResource, PublishableKeyAuthenticable, LogExcludedProtocol {
    private static let idUrlParameter = ":id"
    private static let path = "/tokens"

    case create(_ input: CreateTokenInput)
    case verify(_ tokenId: String, _ input: VerifyTokenInput)
    case refresh(_ tokenId: String, _ input: RefreshTokenInput)
    case delete(_ tokenId: String)

    var authToken: String? {
        var password = ""
        switch self {
        case .create, .verify:
            password = Container.shared.flexaClient().publishableKey
        case .refresh, .delete:
            guard let jwt = Container.shared.authStore().token?.value else {
                FlexaLogger.info("JWT not available")
                return nil
            }
            password = jwt
        }
        return Data((":" + password).utf8).base64EncodedString()
    }

    var path: String {
        switch self {
        case .create, .refresh:
            return Self.path
        case .verify, .delete:
            return "\(Self.path)/\(Self.idUrlParameter)"
        }
    }

    var method: RequestMethod {
        switch self {
        case .create, .refresh:
            return .post
        case .verify:
            return .patch
        case .delete:
            return .delete
        }
    }

    var pathParams: [String: String]? {
        switch self {
        case .create:
            return nil
        case .verify(let tokenId, _), .refresh(let tokenId, _), .delete(let tokenId):
            return [Self.idUrlParameter: tokenId]
        }
    }

    var bodyParams: [String: Any]? {
        switch self {
        case .create(let input):
            return input.dictionary
        case .verify(_, let input):
            return input.dictionary
        case .refresh(_, let input):
            return input.dictionary
        case .delete:
            return nil
        }
    }

    var allowRetry: Bool {
        false
    }

    func wrappingError(_ error: Error?, traceId: String?) -> Error? {
        switch self {
        case .create:
            ReasonableError(reason: .cannotCreateToken(error))
        case .verify:
            ReasonableError(reason: .cannotVerifyToken(error))
        case .refresh:
            ReasonableError(reason: .cannotRefreshToken(error))
        case .delete:
            ReasonableError(reason: .cannotDeleteToken(error))
        }
    }
}
