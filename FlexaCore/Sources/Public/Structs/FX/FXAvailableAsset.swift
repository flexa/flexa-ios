//
//  FXAvailableAsset.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 10/18/22.
//  Copyright © 2022 Flexa. All rights reserved.
//
import Foundation
import UIKit

public struct FXAvailableAsset {
    @available(*, deprecated, message: "logoImageUrl will be removed in future iterations. Use icon instead")
    public let logoImageUrl: URL?

    /// An accent color for the asset to be used in Dark Mode or Light Mode (via dynamicProvider).
    public let accentColor: UIColor?

    /// The CAIP-19 ID for the asset. If you need guidance on selecting the correct CAIP-19 ID for the assets supported by your app, please contact Flexa.
    public let assetId: String

    /// A custom display name to be used when representing this asset throughout Flexa SDK. Supply the asset display name if you would like to ensure that assets are represented exactly as they appear throughout the rest of your app’s interface (for example, if you refer to the native asset of Ethereum as “Ethereum” instead of “Ether,” you should provide a custom display name of `Ethereum`).
    public let displayName: String?

    /// The icon image you use to represent this asset throughout your app’s interface.
    public let icon: UIImage?

    /// A custom symbol to be used when representing this asset throughout Flexa SDK. Supply the asset symbol if you offer your users the ability to customize symbols, or if you would simply like to ensure that asset balances are represented exactly as they appear throughout the rest of your app’s interface (for example, if you use the symbol “SepETH” to represent balances on Ethereum’s Sepolia testnet, you should provide a custom symbol of `SepETH`).
    public let symbol: String

    /// The decimal balance of the asset in this account, using as many units of precision as it is possible for your app to provide.
    public let balance: Decimal

    public init(assetId: String,
                symbol: String,
                balance: Decimal,
                icon: UIImage? = nil,
                displayName: String? = nil,
                logoImageUrl: URL? = nil,
                accentColor: UIColor? = nil
    ) {
        self.assetId = assetId
        self.symbol = symbol
        self.balance = balance
        self.displayName = nil
        self.icon = icon
        self.accentColor = accentColor
        self.logoImageUrl = logoImageUrl
    }
}

public extension Array where Element == FXAvailableAsset {
    func findBy(assetId: String) -> FXAvailableAsset? {
        first { $0.assetId.caseInsensitiveCompare(assetId) == .orderedSame }
    }
}
