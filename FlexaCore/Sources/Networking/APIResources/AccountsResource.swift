//
//  AccountsResource.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import FlexaNetworking
import Factory
import Foundation

enum AccountsResource: FlexaAPIResource, Authenticable {
    case create(_: CreateAccountInput)
    case get
    case delete

    var authToken: String? {
        switch self {
        case .create:
            return DefaultPublishableKeyAuthenticable().authToken
        default:
            return DefaultJWTAuthenticable().authToken
        }
    }

    var method: RequestMethod {
        switch self {
        case .create, .delete:
            return .post
        default:
            return .get
        }
    }

    var path: String {
        switch self {
        case .create:
            return "/accounts"
        case .get:
            return "/accounts/me"
        case .delete:
            return "/accounts/me/initiate_deletion"
        }
    }

    var bodyParams: [String: Any]? {
        switch self {
        case .create(let input):
            return input.dictionary
        default:
            return nil
        }
    }

    var allowRetry: Bool {
        switch self {
        case .create:
            return false
        default:
            return true
        }
    }

    func wrappingError(_ error: Error?, traceId: String?) -> Error? {
        switch self {
        case .create:
            return ReasonableError.withReason(.cannotCreateAccount(error))
        case .get:
            return ReasonableError.withReason(.cannotGetAccount(error))
        case .delete:
            return ReasonableError.withReason(.cannotDeleteAccount(error))
        }
    }
}
