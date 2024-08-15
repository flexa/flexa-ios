//
//  TokenModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension Models {
    struct Token: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case id, value
            case statusString = "status"
            case expiresAt = "expires_at"
        }

        var id: String
        var statusString: String
        var value: String?
        var expiresAt: Int?
    }
}

extension Models.Token {
    var isExpired: Bool {
        guard status != .expired else {
            return true
        }

        guard let expiresAt else {
            return false
        }
        return expiresAt < Int(Date().timeIntervalSince1970)
    }

    var isActive: Bool {
        status == .active
    }

    var expiringIn: Int? {
        guard let expiresAt, !isExpired else {
            return nil
        }
        return expiresAt - Int(Date().timeIntervalSince1970)
    }

    var status: Status {
        Status(rawValue: statusString) ?? .unknown
    }
}

extension Models.Token {
    enum Status: String {
        case requiresEmailVerification = "requires_email_verification"
        case requiresWebAuthnChallenge = "requires_webauthn_challenge"
        case active, expired, unknown
    }
}
