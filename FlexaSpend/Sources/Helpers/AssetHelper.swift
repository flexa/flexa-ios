//
//  File.swift
//
//  Created by Rodrigo Ordeix on 27/5/24.
//

import UIKit
import Factory
import SwiftUI

protocol AssetHelperProtocol {
    func assetWithKey(for asset: AssetWrapper) -> AppAccountAsset
    func symbol(for: AssetWrapper) -> String
    func displayName(for: AssetWrapper) -> String
    func logoImageUrl(for: AssetWrapper) -> URL?
    func logoImage(for: AssetWrapper) -> UIImage?
    func color(for asset: AssetWrapper) -> Color?
    func fxAccount(for: AssetWrapper) -> FXAppAccount?
    func fxAsset(_ asset: AssetWrapper) -> FXAvailableAsset?
    func usdAvailableBalance(_ asset: AssetWrapper) -> Decimal?
    func exchangeRate(_ asset: AssetWrapper) -> ExchangeRate?
}

struct AssetHelper: AssetHelperProtocol {
    @Injected(\.flexaClient) var flexaClient
    @Injected(\.appAccountsRepository) var appAccountsRepository
    @Injected(\.assetsRepository) var assetsRepository
    @Injected(\.exchangeRatesRepository) var exchangeRatesRepository

    func assetWithKey(for asset: AssetWrapper) -> AppAccountAsset {
        if asset.asset.assetKey != nil {
            return asset.asset
        }

        let isLivemode = assetsRepository.assets.findBy(id: asset.assetId)?.livemode ?? false

        let matchingAssetIds = assetsRepository
            .assets
            .filter { $0.livemode == isLivemode }
            .map { $0.id }

        let assetWithKey = appAccountsRepository.appAccounts
            .compactMap { $0.accountAssets }
            .joined()
            .first { $0.assetKey != nil && matchingAssetIds.contains($0.assetId) }

        return assetWithKey ?? asset.asset
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
        fxAsset(for: asset.asset, in: asset.appAccount)
    }

    func fxAsset(for asset: AppAccountAsset, in appAccount: any AppAccount) -> FXAvailableAsset? {
        flexaClient
            .appAccounts
            .findBy(accountId: appAccount.accountId)?
            .availableAssets
            .findBy(assetId: asset.assetId)
    }

    func exchangeRate(_ asset: AssetWrapper) -> ExchangeRate? {
        exchangeRatesRepository.find(by: asset.assetId, unitOfAccount: FlexaConstants.usdAssetId)
    }

    func usdAvailableBalance(_ asset: AssetWrapper) -> Decimal? {
        guard let availableBalance = fxAsset(asset)?.balanceAvailable,
              let exchangeRate = exchangeRate(asset) else {
            return nil
        }

        return (availableBalance * exchangeRate.decimalPrice).rounded(places: exchangeRate.precision)
    }
}
