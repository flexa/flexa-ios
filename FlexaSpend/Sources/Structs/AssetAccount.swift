//
//  AssetAccount.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 10/3/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

struct AssetAccount: Identifiable {
    let id: String
    var assets: [AssetWrapper]

    init(id: String, assets: [AssetWrapper]) {
        self.id = id
        self.assets = assets
    }

    init(_ assetAccount: FXAssetAccount) {
        self.id = assetAccount.assetAccountHash
        self.assets = assetAccount.availableAssets.map {
            AssetWrapper(accountHash: assetAccount.assetAccountHash, assetId: $0.assetId)
        }
    }
}
