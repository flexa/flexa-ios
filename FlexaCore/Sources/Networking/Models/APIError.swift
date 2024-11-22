//
//  APIError.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/21/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

struct APIErrorWrapper: FlexaModelProtocol {
    var error: APIError?
}

struct APIError: FlexaModelProtocol {
    let code: String?
    let message: String?
    let type: String?

    var isRestrictedRegion: Bool {
        code == "region_not_supported"
    }

    var isInvalidTokenError: Bool {
        code == "token_invalid"
    }

    var isExpiredTokenError: Bool {
        code == "token_expired"
    }
}
