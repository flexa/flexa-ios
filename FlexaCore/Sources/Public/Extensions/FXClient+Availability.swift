//
//  FXClientExtensions.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 10/3/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

public extension FXClient {
    var availableFXAssetAccounts: [FXAssetAccount] {
        let assetsRepository = Container.shared.assetsRepository()
        if assetsRepository.assets.isEmpty {
            return assetAccounts
        }

        var FXAssetAccounts: [FXAssetAccount] = []
        let assetsIds = assetsRepository.assets.map { $0.id }

        for account in assetAccounts {
            let fxAssets = account.availableAssets.filter { assetsIds.contains($0.assetId) && $0.balance > 0 }

            if fxAssets.isEmpty {
                continue
            }

            FXAssetAccounts.append(
                FXAssetAccount(
                    assetAccountHash: account.assetAccountHash,
                    displayName: account.displayName,
                    custodyModel: account.custodyModel,
                    availableAssets: fxAssets
                )
            )
        }

        return FXAssetAccounts
    }

    func sanitizeSelectedAsset() {
        let assetConfig = Container.shared.assetConfig()
        guard !availableFXAssetAccounts.contains(assetConfig: assetConfig) else {
            return
        }

        if let account = availableFXAssetAccounts.first,
           let asset = account.availableAssets.first {
            assetConfig.selectedAssetId = asset.assetId
            assetConfig.selectedAssetAccountHash = account.assetAccountHash
        }
    }
}

extension Array where Element == FXAssetAccount {
    func contains(assetConfig: FXAssetConfig) -> Bool {
        contains(where: { account in
            account.assetAccountHash == assetConfig.selectedAssetAccountHash &&
            account.availableAssets.contains(where: { $0.assetId == assetConfig.selectedAssetId })
        })
    }
}
