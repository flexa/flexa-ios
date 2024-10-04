//
//  OneTimeKeyModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/2/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

extension Models {
    struct OneTimeKey: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case id, asset, length, livemode, prefix, secret
            case expiresAt = "expires_at"
        }

        let id: String
        let asset: String
        let expiresAt: Int
        let length: Int
        let livemode: Bool
        let prefix: String
        let secret: String
    }
}

extension Models.OneTimeKey: OneTimeKey {
    var isExpired: Bool {
        Date.now.timeIntervalSince1970 >= TimeInterval(expiresAt)
    }

    var serverTimeOffset: TimeInterval {
        Container.shared.oneTimeKeysRepository().syncDateOffset ?? 0
    }
}
