//
//  FXClient+AssetAccounts.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 10/3/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension FXClient {
    var availableAssetAccounts: [AssetAccount] {
        availableFXAssetAccounts
            .filter { $0.availableAssets.contains(where: { $0.balance > 0 }) }
            .map(AssetAccount.init)
    }
}
