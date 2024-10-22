//
//  OneTimeKeysRepositoryProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/2/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

public protocol OneTimeKeysRepositoryProtocol {
    var keys: [String: OneTimeKey] { get }
    var syncDateOffset: TimeInterval? { get }

    @discardableResult
    func refresh() async throws -> [String: OneTimeKey]
    func backgroundRefresh()
    func purgeAll()
}

public extension OneTimeKeysRepositoryProtocol {
    func find(by asset: String) -> OneTimeKey? {
        keys[asset]
    }

    func find(by asset: String, orLivemode livemode: Bool) -> OneTimeKey? {
        if let key = keys[asset], !key.isExpired {
            return key
        }
        return keys.first { !$0.value.isExpired && $0.value.livemode == livemode }?.value
    }
}
