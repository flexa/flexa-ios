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
    var appAccount: AppAccount
    var asset: AppAccountAsset

    var accountId: String {
        appAccount.accountId
    }

    var assetId: String {
        asset.assetId
    }

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

    var label: String {
        asset.label
    }

    var valueLabel: String {
        asset.assetValue.label
    }

    var valueLabelTitleCase: String {
        asset.assetValue.labelTitleCase
    }

    var assetLogoUrl: URL? {
        assetsHelper.logoImageUrl(for: self)
    }

    var decimalBalance: Decimal {
        asset.decimalBalance
    }

    var assetWithKey: AppAccountAsset {
        assetsHelper.assetWithKey(for: self)
    }

    var exchangeRate: ExchangeRate? {
        assetsHelper.exchangeRate(self)
    }

    var exchange: Decimal? {
        if let exchangeRate = assetsHelper.exchangeRate(self) {
            return exchangeRate.decimalPrice
        }

        guard let decimal = asset.assetValue.label.digitsAndSeparator?.decimalValue else {
            return  nil
        }
        return decimal / decimalBalance
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

    var usdBalance: Decimal? {
        asset.assetValue.label.digitsAndSeparator?.decimalValue
    }

    var availableUSDBalance: Decimal? {
        assetsHelper.usdAvailableBalance(self)
    }

    init(appAccount: AppAccount, asset: AppAccountAsset) {
        self.appAccount = appAccount
        self.asset = asset
    }

    init?(appAccountId: String, assetId: String) {
        let appAccountsRepository = Container.shared.appAccountsRepository()

        guard let account = appAccountsRepository.appAccounts.first(where: { $0.accountId == appAccountId }),
              let asset = account.accountAssets.first(where: { $0.assetId == assetId }) else {
            return nil
        }

        self.appAccount = account
        self.asset = asset
    }

    func enoughBalance(for usdAmount: Decimal) -> Bool {
        availableUSDBalance ?? usdBalance ?? 0 >= usdAmount
    }
}

extension AssetWrapper: Equatable {
    static func == (lhs: AssetWrapper, rhs: AssetWrapper) -> Bool {
        lhs.appAccount.accountId == rhs.appAccount.accountId &&
        lhs.asset.assetId == rhs.asset.assetId
    }
}
