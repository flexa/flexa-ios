//
//  DataSourcesInjection+Core.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 4/24/23.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import Factory
import KeychainAccess
import FlexaNetworking

extension Container {
    var userDefaults: Factory<UserDefaults> {
        self { UserDefaults.flexaStore }.singleton
    }

    var deviceKeychain: Factory<Keychain> {
        self {
            self.keychain(false)
        }.singleton
    }

    var synchronizedKeychain: Factory<Keychain> {
        self {
            self.keychain(true)
        }.singleton
    }

    var keychain: ParameterFactory<Bool, Keychain> {
        self { synchronizable in
            let service = Bundle.main.bundleIdentifier ?? "co.flexa.sdk.\(Bundle.main.name)"
            return Keychain(service: service).synchronizable(synchronizable)
        }
    }

    var authStore: Factory<AuthStoreProtocol> {
        self { AuthStore() }.singleton
    }

    var tokensRepository: Factory<TokensRepositoryProtocol> {
        self { TokensRepository() }.singleton
    }

    var flexaNetworkClient: Factory<Networkable> {
        self { FlexaNetworkService() }
    }
}
