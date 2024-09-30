//
//  DataSourcesInjection.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 4/24/23.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import Factory

public extension Container {
    var flexaClient: Factory<FXClient> {
        self { .empty }.singleton
    }

    var assetConfig: Factory<FXAssetConfig> {
        self { .init() }.singleton
    }

    var appAccountsRepository: Factory<AppAccountsRepositoryProtocol> {
        self { AppAccountsRepository() }.singleton
    }

    var brandsRepository: Factory<BrandsRepositoryProtocol> {
        self { BrandsRepository() }.singleton
    }

    var assetsRepository: Factory<AssetsRepositoryProtocol> {
        self { AssetsRepository() }.singleton
    }

    var commerceSessionRepository: Factory<CommerceSessionsRepositoryProtocol> {
        self { CommerceSessionsRepository() }
    }

    var transactionsRespository: Factory<TransactionsRepositoryProtocol> {
        self { TransactionsRepository() }.singleton
    }

    var assetConverterRepository: Factory<AssetConverterRepositoryProtocol> {
        self { AssetConverterRepository() }.singleton
    }

    var accountRepository: Factory<AccountsRepositoryProtocol> {
        self { AccountsRepository() }.singleton
    }

    var appNotificationsRepository: Factory<AppNotificationsRepositoryProtocol> {
        self { AppNotificationsRepository() }.singleton
    }

    var exchangeRatesRepository: Factory<ExchangeRatesRepositoryProtocol> {
        self { ExchangeRatesRepository() }.singleton
    }
}
