//
//  File.swift
//
//  Created by Rodrigo Ordeix on 27/5/24.
//

import UIKit
import Factory
import SwiftUI

protocol AssetHelperProtocol {
    func oneTimeKey(for asset: AssetWrapper) -> OneTimeKey?
    func symbol(for: AssetWrapper) -> String
    func displayName(for: AssetWrapper) -> String
    func logoImageUrl(for: AssetWrapper) -> URL?
    func logoImage(for: AssetWrapper) -> UIImage?
    func color(for asset: AssetWrapper) -> Color?
    func fxAccount(for: AssetWrapper) -> FXAppAccount?
    func fxAsset(_ asset: AssetWrapper) -> FXAvailableAsset?
    func balanceInLocalCurrency(_ asset: AssetWrapper) -> Decimal
    func availableBalanceInLocalCurrency(_ asset: AssetWrapper) -> Decimal?
    func exchangeRate(_ asset: AssetWrapper) -> ExchangeRate?
}

struct AssetHelper: AssetHelperProtocol {
    @Injected(\.flexaClient) var flexaClient
    @Injected(\.assetsRepository) var assetsRepository
    @Injected(\.exchangeRatesRepository) var exchangeRatesRepository
    @Injected(\.oneTimeKeysRepository) var oneTimeKeysRepository

    func oneTimeKey(for asset: AssetWrapper) -> OneTimeKey? {
        let isLivemode = assetsRepository.assets.findBy(id: asset.assetId)?.livemode ?? false
        return oneTimeKeysRepository.find(by: asset.assetId, orLivemode: isLivemode)
    }

    func logoImage(for asset: AssetWrapper) -> UIImage? {
        fxAsset(asset)?.icon
    }

    func symbol(for asset: AssetWrapper) -> String {
        if let symbol = fxAsset(asset)?.symbol, !symbol.isEmpty {
            return symbol
        }

        return assetsRepository.assets.findBy(id: asset.assetId)?.symbol ?? ""
    }

    func logoImageUrl(for asset: AssetWrapper) -> URL? {
        fxAsset(asset)?.logoImageUrl ?? assetsRepository.assets.findBy(id: asset.assetId)?.iconUrl
    }

    func displayName(for asset: AssetWrapper) -> String {
        fxAsset(asset)?.displayName ?? assetsRepository.assets.findBy(id: asset.assetId)?.displayName ?? ""
    }

    func color(for asset: AssetWrapper) -> Color? {
        assetsRepository.assets.findBy(id: asset.assetId)?.color
    }

    func fxAccount(for asset: AssetWrapper) -> FlexaCore.FXAppAccount? {
        flexaClient.appAccounts.findBy(accountId: asset.accountId)
    }

    func fxAsset(_ asset: AssetWrapper) -> FXAvailableAsset? {
        fxAsset(assetId: asset.assetId, appAccountId: asset.accountId)
    }

    func fxAsset(assetId: String, appAccountId: String) -> FXAvailableAsset? {
        flexaClient
            .appAccounts
            .findBy(accountId: appAccountId)?
            .availableAssets
            .findBy(assetId: assetId)
    }

    func exchangeRate(_ asset: AssetWrapper) -> ExchangeRate? {
        exchangeRatesRepository.find(by: asset.assetId, unitOfAccount: FlexaConstants.usdAssetId)
    }

    func balanceInLocalCurrency(_ asset: AssetWrapper) -> Decimal {
        guard let availableBalance = fxAsset(asset)?.balance else {
            return 0
        }

        return amountInLocalCurrency(availableBalance, asset: asset) ?? 0
    }

    func availableBalanceInLocalCurrency(_ asset: AssetWrapper) -> Decimal? {
        guard let availableBalance = fxAsset(asset)?.balanceAvailable else {
            return nil
        }

        return amountInLocalCurrency(availableBalance, asset: asset)
    }

    func amountInLocalCurrency(_ amount: Decimal, asset: AssetWrapper) -> Decimal? {
        guard let exchangeRate = exchangeRate(asset) else {
            return nil
        }

        return (amount * exchangeRate.decimalPrice).rounded(places: exchangeRate.precision)
    }
}
