//
//  AppAccountsRepository.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 3/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

class AppAccountsRepository: AppAccountsRepositoryProtocol {
    @Injected(\.flexaNetworkClient) private var networkClient
    @Injected(\.flexaClient) private var flexaClient
    @Injected(\.deviceKeychain) private var keychain
    @Injected(\.assetsRepository) private var assetsRepository
    @Injected(\.assetConfig) private var assetConfig
    @Injected(\.keychainHelper) private var keychainHelper
    @Injected(\.eventNotifier) private var eventNotifier

    var appAccounts: [AppAccount] {
        storedAppAccounts
    }

    var syncDateOffset: TimeInterval? {
        didSet {
            keychainHelper.setValue(syncDateOffset, forKey: .lastAppAccountsSyncOffset)
        }
    }

    @Synchronized private var storedAppAccounts: [Models.AppAccount] = [] {
        didSet {
            keychainHelper.setValue(storedAppAccounts, forKey: .appAccounts)
            eventNotifier.post(name: .appAccountsDidUpdate)
        }
    }

    var availableAppAccounts: [FXAppAccount] {
        if assetsRepository.assets.isEmpty {
            return flexaClient.appAccounts
        }

        var fxAppAccounts: [FXAppAccount] = []
        let assetsIds = assetsRepository.assets.map { $0.id }

        for appAccount in flexaClient.appAccounts {
            let fxAssets = appAccount.availableAssets.filter { assetsIds.contains($0.assetId) && $0.balance > 0
            }

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

    init() {
        storedAppAccounts = keychainHelper.value(forKey: .appAccounts) ?? []
        syncDateOffset = keychainHelper.value(forKey: .lastAppAccountsSyncOffset)
    }

    @discardableResult
    func refresh() async throws -> [AppAccount] {
        var output: RefreshAppAccountsOutput?
        var response: HTTPURLResponse?
        var error: Error?

        (output, response, error) = await networkClient.sendRequest(
            resource: AppAccountsResource.refresh(
                RefreshAppAccountsInput(accounts: availableAppAccounts)
            )
        )

        if let error {
            syncDateOffset = nil
            storedAppAccounts = []
            throw error
        }

        guard let response, let output else {
            syncDateOffset = nil
            storedAppAccounts = []
            return appAccounts
        }

        syncDateOffset = Date().timeIntervalSince1970 - (response.responseDate?.timeIntervalSince1970 ?? 0)
        storedAppAccounts = output.data
        sanitizeSelectedAsset()
        return appAccounts
    }

    func backgroundRefresh() {
        Task {
            do {
                try await refresh()
            } catch let error {
                FlexaLogger.error(error)
            }
        }
    }

    func sanitizeSelectedAsset() {
        if let appAccount = appAccounts.first(where: { $0.accountId == assetConfig.selectedAppAccountId }),
           let asset = appAccount.accountAssets.first(where: { $0.assetId == assetConfig.selectedAssetId }),
           let fxAppAccount = flexaClient.appAccounts.findBy(accountId: assetConfig.selectedAppAccountId),
           fxAppAccount.availableAssets.findBy(assetId: assetConfig.selectedAssetId) != nil {
            return
        }

        if let appAccount = appAccounts.first,
           let asset = appAccount.accountAssets.first,
           let fxAppAccount = flexaClient.appAccounts.findBy(accountId: appAccount.accountId),
           fxAppAccount.availableAssets.findBy(assetId: asset.assetId) != nil {
            assetConfig.selectedAssetId = asset.assetId
            assetConfig.selectedAppAccountId = appAccount.accountId
        }
    }
}
