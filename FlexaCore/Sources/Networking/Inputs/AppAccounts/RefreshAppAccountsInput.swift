//
//  RefreshAppAccountsInput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

struct RefreshAppAccountsInput: FlexaModelProtocol {
    let data: [Account]

    init(data: [Account]) {
        self.data = data
    }

    init(accounts: [FXAppAccount]) {
        self.data = accounts.map(Account.init)
    }
}

extension RefreshAppAccountsInput {
    struct Account: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case assets
            case accountId = "account_id"
        }

        let accountId: String
        let assets: [Asset]

        init(accountId: String, assets: [Asset]) {
            self.accountId = accountId
            self.assets = assets
        }

        init(account: FXAppAccount) {
            self.accountId = account.accountId
            self.assets = account.availableAssets.map(Asset.init)
        }
    }

    struct Asset: FlexaModelProtocol {
        let asset: String
        let balance: String
        let symbol: String?

        init(asset: String, balance: String, symbol: String? = nil) {
            self.asset = asset
            self.balance = balance
            self.symbol = symbol
        }

        init(_ asset: FXAvailableAsset) {
            self.asset = asset.assetId
            self.balance = asset.balance.apiFormatted
            self.symbol = asset.symbol
        }
    }
}
