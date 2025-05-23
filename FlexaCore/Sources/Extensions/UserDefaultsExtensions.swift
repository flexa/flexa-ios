//
//  UserDefaultsExtensions.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 12/15/20.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation

public extension UserDefaults {
    private enum Storage {
        static let name = "flexa_public_data"
    }

    enum Key: String, CaseIterable {
        case pinnedBrandIds = "pinned_brand_ids"
        case brands = "brands"
        case legacyBrands = "legacy_brands"
        case assets = "assets"
        case exchangeRates = "exchange_rates"
        case transactionFees = "transaction_fees"
        case apiHost = "flexa_api_host"
        case hasRunBefore = "has_run_before"
        case payWithFlexaEnabled = "pay_with_flexa_enabled"
    }

    static let flexaStore = UserDefaults(suiteName: Storage.name) ?? UserDefaults.standard

    func value<T>(forKey key: Key) -> T? {
        return value(forKey: key.rawValue) as? T
    }

    func setValue(_ value: Any?, forKey key: Key) {
        set(value, forKey: key.rawValue)
    }

    func setEncodedValue<T: Encodable>(_ value: T?, forKey key: UserDefaults.Key) {
        if let value {
            try? setValue(JSONEncoder().encode(value), forKey: key)
        } else {
            setValue(nil, forKey: key)
        }
    }

    func getDecodedValue<T: Decodable>(forKey key: UserDefaults.Key) -> T? {
        let data: Data? = value(forKey: key)
        guard let data else {
            return nil
        }
        return (try? JSONDecoder().decode(T.self, from: data))
    }

    func purgeAll() {
        Key.allCases
            .filter { $0 != .apiHost && $0 != .payWithFlexaEnabled }
            .forEach { removeObject(forKey: $0.rawValue) }
    }
}
