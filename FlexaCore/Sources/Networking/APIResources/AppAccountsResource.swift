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

enum AppAccountsResource: FlexaAPIResource, JWTAuthenticable {
    case refresh(_ appAccounts: RefreshAppAccountsInput)

    var method: RequestMethod {
        .put
    }

    var path: String {
        "/accounts/me/app_accounts"
    }

    var bodyParams: [String: Any]? {
        switch self {
        case .refresh(let input):
            input.dictionary
        }
    }
}
