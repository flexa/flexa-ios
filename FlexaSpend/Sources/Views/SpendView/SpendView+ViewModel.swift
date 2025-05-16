//
//  SpendView+ViewModel.swift
//  FlexaSpend
//
//  Created by Marcelo Korjenioski on 12/15/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import FlexaCore
import Combine
import SwiftUI
import Factory

extension SpendView {
    class ViewModel: ObservableObject, Identifiable {
        enum State: Equatable {
            case loading
            case accountsLoaded
            case commerceSessionCreated
            case commerceSessionUpdated
            case transactionSent
            case commerceSessionCompleted
            case error(Error)

            public static func == (lhs: State, rhs: State) -> Bool {
                switch (lhs, rhs) {
                case (.loading, .loading),
                    (.accountsLoaded, .accountsLoaded),
                    (.commerceSessionCreated, .commerceSessionCreated),
                    (.commerceSessionUpdated, .commerceSessionUpdated),
                    (.transactionSent, .transactionSent),
                    (.commerceSessionCompleted, .commerceSessionCompleted):
                    return true
                case (.error(let lhsError), .error(let rhsError)):
                    return lhsError.localizedDescription == rhsError.localizedDescription
                default:
                    return false
                }
            }
        }

        @Injected(\.transactionsRespository) var transactionsRepository
        @Injected(\.flexaClient) var flexaClient
        @Injected(\.assetConfig) var assetConfig
        @Injected(\.appStateManager) var appStateManager
        @Injected(\.flexcodeGenerator) var flexcodeGenerator
        @Injected(\.eventNotifier) var eventNotifier
        @Injected(\.exchangeRatesRepository) var exchangeRatesRepository
        @Injected(\.oneTimeKeysRepository) var oneTimeKeysRepository
        @Injected(\.accountRepository) var accountRepository

        @Published var assetSwitcherEnabled = true
        var accounts: [AssetAccount] {
            commerceSessionViewModel.accounts
        }
        @Published var invalidUserAssets: [FXAvailableAsset] = []
        @Published var error: Error?
        @Published var flexCodes: [SpendCodeView.ViewModel] = []
        @Published var isShowingWebView = false

        @Published var showManageFlexaAccountSheet = false
        @Published var state = State.loading
        @Published var commerceSessionViewModel: CommerceSessionView.ViewModel!
        @Published var isSignedIn = FlexaIdentity.isSignedIn

        var paymentCompleted: Bool {
            commerceSessionViewModel.commerceSessionHandler.paymentCompleted
        }

        @Synchronized var isUpdatingPaymentAsset = false

        var signTransaction: Flexa.TransactionRequestCallback? {
            didSet {
                commerceSessionViewModel.commerceSessionHandler.signTransaction = signTransaction
            }
        }

        var onPaymentAuthorization: Flexa.PaymentAuthorizationCallback? {
            didSet {
                commerceSessionViewModel.commerceSessionHandler.onPaymentAuthorization = onPaymentAuthorization
            }
        }

        var sendTransactionWhenAvailable = false
        var legacyMode = false
        var legacyCommerceSessionIds: [String] = []
        var isStandAlone: Bool = true
        var url: URL?

        var selectedAsset: AssetWrapper? {
            commerceSessionViewModel.viewModelAsset.selectedAsset
        }

        var selectedAssetSymbol: String {
            selectedAsset?.assetSymbol ?? ""
        }

        var showInvalidAssetMessage: Bool {
            if state == .loading {
                return false
            }
            return missingAccounts
        }

        var showInlineNavigationTitle: Bool {
            state == .loading || missingAccounts
        }

        var showLegacyFlexcodeList: Bool {
            state != .loading && !showInvalidAssetMessage
        }

        var missingAccounts: Bool {
            accounts.isEmpty || accounts.allSatisfy { $0.assets.isEmpty }
        }

        required init(signTransaction: ((Result<FXTransaction, Error>) -> Void)?) {
            self.signTransaction = signTransaction

            commerceSessionViewModel = CommerceSessionView.ViewModel(
                signTransaction: signTransaction)
        }

        deinit {
            eventNotifier.removeObserver(self)
        }

        func brandSelected(_ brand: Brand?) {
            commerceSessionViewModel.brandSelected(brand)
        }

        @MainActor
        func setError(_ error: Error?) {
            self.error = error
        }

        func showAssetInfo() {
            Task {
                await MainActor.run {
                    commerceSessionViewModel.viewModelAsset.amount = 0
                    commerceSessionViewModel.viewModelAsset.hasAmount = false
                    commerceSessionViewModel.viewModelAsset.showSelectedAssetDetail = false
                    commerceSessionViewModel.showAssetsModal = true
                }
            }
        }
    }
}

extension SpendView.ViewModel {
    private func updateInvalidAssets() {
        let validAssetIds = accounts
            .map { $0.assets }
            .joined()
            .filter { $0.balance > 0 && $0.oneTimekey != nil }
            .map { $0.assetId }

        invalidUserAssets = flexaClient.assetAccounts
            .map { $0.availableAssets }
            .joined()
            .filter { !validAssetIds.contains($0.assetId) && $0.balance > 0 }
            .reduce(into: [FXAvailableAsset]()) { partialResult, fxAsset in
                if !partialResult.contains(where: { $0.assetId == fxAsset.assetId }) {
                    partialResult.append(fxAsset)
                }
            }
    }

    private func updateAccounts() {
        if state == .loading {
            state = .accountsLoaded
        }

        flexCodes = accounts.reduce(into: [SpendCodeView.ViewModel]()) { partialResult, account in
            partialResult.append(
                contentsOf: account
                    .assets
                    .map { SpendCodeView.ViewModel(asset: $0) }
            )
        }
        updateInvalidAssets()
    }

    func clear(canceled: Bool = false) {
        if canceled && (!legacyMode && !paymentCompleted || legacyMode) {
            signTransaction?(.failure(FXError.transactionCanceledByUser))
        }
        if appStateManager.closeCommerceSessionOnDismissal ||
            canceled {
            commerceSessionViewModel.closeCommerceSession()
        }
        legacyMode = false
        sendTransactionWhenAvailable = false
        isUpdatingPaymentAsset = false
        state = .accountsLoaded
        accountRepository.backgroundRefresh()
        eventNotifier.removeObserver(self)
    }

    func setup() {
        setupSubscriptions()
        if !accounts.isEmpty {
            updateAccounts()
        }
        Task {
            do {
                try await oneTimeKeysRepository.refresh()
            } catch let error {
                FlexaLogger.error(error)
            }
            handleAccountsDidUpdate()
        }
    }

    func setupSubscriptions() {
        eventNotifier.addObserver(self, selector: #selector(stopWatchingEvents), name: .flexaComponentScanSelected)
        eventNotifier.addObserver(self, selector: #selector(startWatchingEvents), name: .flexaComponentSpendSelected)
    }

    @objc func stopWatchingEvents() {
        commerceSessionViewModel.stopWatching()
    }

    @objc func startWatchingEvents() {
        commerceSessionViewModel.startWatching()
    }

    func refreshFlexcodes() {
        flexCodes.forEach { $0.updateIfNeeded() }
    }

    @objc func handleAccountsDidUpdate() {
        Task {
            await MainActor.run {
                updateAccounts()
            }
        }
    }
}
