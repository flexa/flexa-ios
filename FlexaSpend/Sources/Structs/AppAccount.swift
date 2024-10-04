//
//  AppAccount.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 10/3/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

struct AppAccount: Identifiable {
    let id: String
    var assets: [AssetWrapper]

    init(id: String, assets: [AssetWrapper]) {
        self.id = id
        self.assets = assets
    }

    init(_ appAccount: FXAppAccount) {
        self.id = appAccount.accountId
        self.assets = appAccount.availableAssets.map {
            AssetWrapper(appAccountId: appAccount.accountId, assetId: $0.assetId)
        }
    }
}
