//
//  KeychainHelper.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/31/24.
//  Copyright © 2024 Flexa. All rights reserved.
//
import Foundation
import Factory
import KeychainAccess

enum KeychainKey: String, CaseIterable {
    case authToken = "auth-token-data"
    case appAccounts = "accounts-data"
    case flexaAccount = "flexa-account"
    case lastAppAccountsSyncOffset = "accounts-data-sync-date-offset"
    case deletedAppNotifications = "deleted-app-notifications"
    case currentCommerceSession = "current-commerce-session"
}

protocol KeychainHelperProtocol {
    func purgeAll()
    func value<T: FlexaModelProtocol>(forKey key: KeychainKey) -> T?
    func setValue(_ value: (any FlexaModelProtocol)?, forKey key: KeychainKey)
}

struct KeychainHelper: KeychainHelperProtocol {
    @Injected(\.deviceKeychain) private var deviceKeychain
    @Injected(\.synchronizedKeychain) private var synchronizedKeychain

    func keychains(forKey key: KeychainKey) -> [Keychain] {
        switch key {
        case .authToken, .deletedAppNotifications, .currentCommerceSession:
            return [synchronizedKeychain]
        default:
            return [deviceKeychain]
        }
    }

    func value<T>(forKey key: KeychainKey) -> T? where T: FlexaModelProtocol {
        let keychains = keychains(forKey: key)
        let data = keychains.compactMap {
            try? $0.getData(key.rawValue)
        }.first

        guard let data else {
            return nil
        }
        return try? T(data: data)
    }

    func setValue(_ value: (any FlexaModelProtocol)?, forKey key: KeychainKey) {
        let keychains = keychains(forKey: key)
        guard let value, let data = try? value.jsonData() else {
            keychains.forEach { try? $0.remove(key.rawValue) }
            return
        }

        keychains.forEach {
            try? $0.set(data, key: key.rawValue)
        }
    }

    func purgeAll() {
        do {
            try deviceKeychain.removeAll()
            try synchronizedKeychain.removeAll()
        } catch let error {
            FlexaLogger.error(error)
        }
    }
}
