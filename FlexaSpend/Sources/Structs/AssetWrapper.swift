//
//  AssetWrapper.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 5/27/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory
import UIKit
import SwiftUI

struct AssetWrapper: Identifiable {
    @Injected(\.assetsHelper) var assetsHelper

    let id = UUID()
    var accountId: String
    var assetId: String

    var assetDisplayName: String {
        let displayName = assetsHelper.displayName(for: self)
        return displayName.isEmpty ? assetSymbol : displayName
    }

    var assetSymbol: String {
        assetsHelper.symbol(for: self)
    }

    var logoImage: UIImage? {
        assetsHelper.logoImage(for: self)
    }

    var logoImageUrl: URL? {
        assetsHelper.logoImageUrl(for: self)
    }

    var assetLogoUrl: URL? {
        assetsHelper.logoImageUrl(for: self)
    }

    var balance: Decimal {
        assetsHelper.fxAsset(self)?.balance ?? 0
    }

    var exchangeRate: ExchangeRate? {
        assetsHelper.exchangeRate(self)
    }

    var oneTimekey: OneTimeKey? {
        assetsHelper.oneTimeKey(for: self)
    }

    var exchange: Decimal? {
        if let exchangeRate = assetsHelper.exchangeRate(self) {
            return exchangeRate.decimalPrice
        }

        guard let balance = assetsHelper.fxAsset(self)?.balance else {
            return  nil
        }
        return balance / self.balance
    }

    var gradientColors: [Color] {
        []
    }

    var assetColor: Color? {
        assetsHelper.color(for: self)
    }

    var isUpdatingBalance: Bool {
        assetsHelper.fxAsset(self)?.isUpdatingBalance ?? false
    }

    var balanceInLocalCurrency: Decimal? {
        assetsHelper.balanceInLocalCurrency(self)
    }

    var availableBalanceInLocalCurrency: Decimal? {
        assetsHelper.availableBalanceInLocalCurrency(self)
    }

    init(accountHash: String, assetId: String) {
        self.accountId = accountHash
        self.assetId = assetId
    }

    func enoughBalance(for usdAmount: Decimal) -> Bool {
        availableBalanceInLocalCurrency ?? balanceInLocalCurrency ?? 0 >= usdAmount
    }
}

extension AssetWrapper: Hashable {
    static func == (lhs: AssetWrapper, rhs: AssetWrapper) -> Bool {
        lhs.accountId == rhs.accountId &&
        lhs.assetId == rhs.assetId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
