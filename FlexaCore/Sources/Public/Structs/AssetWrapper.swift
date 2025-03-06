//
//  AssetWrapper.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/27/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory
import UIKit
import SwiftUI

public struct AssetWrapper: Identifiable {
    @Injected(\.assetsHelper) var assetsHelper

    public let id = UUID()
    public var accountId: String
    public var assetId: String

    public var assetDisplayName: String {
        let displayName = assetsHelper.displayName(for: self)
        return displayName.isEmpty ? assetSymbol : displayName
    }

    public var assetSymbol: String {
        assetsHelper.symbol(for: self)
    }

    public var logoImage: UIImage? {
        assetsHelper.logoImage(for: self)
    }

    public var logoImageUrl: URL? {
        assetsHelper.logoImageUrl(for: self)
    }

    public var assetLogoUrl: URL? {
        assetsHelper.logoImageUrl(for: self)
    }

    public var balance: Decimal {
        assetsHelper.fxAsset(self)?.balance ?? 0
    }

    public var exchangeRate: ExchangeRate? {
        assetsHelper.exchangeRate(self)
    }

    public var oneTimekey: OneTimeKey? {
        assetsHelper.oneTimeKey(for: self)
    }

    public var exchange: Decimal? {
        if let exchangeRate = assetsHelper.exchangeRate(self) {
            return exchangeRate.decimalPrice
        }

        guard let balance = assetsHelper.fxAsset(self)?.balance else {
            return  nil
        }
        return balance / self.balance
    }

    public var gradientColors: [Color] {
        []
    }

    public var assetColor: Color? {
        assetsHelper.color(for: self)
    }

    public var isUpdatingBalance: Bool {
        assetsHelper.fxAsset(self)?.isUpdatingBalance ?? false
    }

    public var balanceInLocalCurrency: Decimal? {
        assetsHelper.balanceInLocalCurrency(self)
    }

    public var availableBalanceInLocalCurrency: Decimal? {
        assetsHelper.availableBalanceInLocalCurrency(self)
    }

    public init(accountHash: String, assetId: String) {
        self.accountId = accountHash
        self.assetId = assetId
    }

    public func enoughBalance(for usdAmount: Decimal) -> Bool {
        availableBalanceInLocalCurrency ?? balanceInLocalCurrency ?? 0 >= usdAmount
    }
}

extension AssetWrapper: Hashable {
    public static func == (lhs: AssetWrapper, rhs: AssetWrapper) -> Bool {
        lhs.accountId == rhs.accountId &&
        lhs.assetId == rhs.assetId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
