//
//  AppAccount.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/20/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol AppAccount {
    var accountId: String { get }
    var accountAssets: [any AppAccountAsset] { get set }
}

public protocol AppAccountAsset {
    var assetId: String { get }
    var balance: String { get }
    var assetKey: AppAccountAssetKey? { get }
    var assetValue: AppAccountAssetValue { get }
    var label: String { get }
}

public extension AppAccountAsset {
    var decimalBalance: Decimal {
        Decimal(string: balance) ?? 0
    }
}

public protocol AppAccountAssetKey {
    var serverTimeOffset: TimeInterval { get }
    var expiresAt: Int { get }
    var length: Int { get }
    var prefix: String { get }
    var secret: String { get }
}

public protocol AppAccountAssetValue {
    var asset: String { get }
    var label: String { get }
    var labelTitleCase: String { get }
}
