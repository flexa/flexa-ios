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
    var availableFXAppAccounts: [FXAppAccount] {
        let assetsRepository = Container.shared.assetsRepository()
        if assetsRepository.assets.isEmpty {
            return appAccounts
        }

        var fxAppAccounts: [FXAppAccount] = []
        let assetsIds = assetsRepository.assets.map { $0.id }

        for appAccount in appAccounts {
            let fxAssets = appAccount.availableAssets.filter { assetsIds.contains($0.assetId) && $0.balance > 0 }

            if fxAssets.isEmpty {
                continue
            }

            fxAppAccounts.append(
                FXAppAccount(
                    accountId: appAccount.accountId,
                    displayName: appAccount.displayName,
                    custodyModel: appAccount.custodyModel,
                    availableAssets: fxAssets
                )
            )
        }

        return fxAppAccounts
    }

    func sanitizeSelectedAsset() {
        let assetConfig = Container.shared.assetConfig()
        guard !availableFXAppAccounts.contains(assetConfig: assetConfig) else {
            return
        }

        if let appAccount = availableFXAppAccounts.first,
           let asset = appAccount.availableAssets.first {
            assetConfig.selectedAssetId = asset.assetId
            assetConfig.selectedAppAccountId = appAccount.accountId
        }
    }
}

extension Array where Element == FXAppAccount {
    func contains(assetConfig: FXAssetConfig) -> Bool {
        contains(where: { appAccount in
            appAccount.accountId == assetConfig.selectedAppAccountId &&
            appAccount.availableAssets.contains(where: { $0.assetId == assetConfig.selectedAssetId })
        })
    }
}
