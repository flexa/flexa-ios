//
//  FXClient+AppAccounts.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 10/3/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension FXClient {
    var availableAppAccounts: [AppAccount] {
        availableFXAppAccounts
            .filter { $0.availableAssets.contains(where: { $0.balance > 0 }) }
            .map(AppAccount.init)
    }
}
