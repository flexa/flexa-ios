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
            case appAccountsLoaded
            case commerceSessionCreated
            case commerceSessionUpdated
            case transactionSent
            case commerceSessionCompleted
            case error(Error)

            public static func == (lhs: State, rhs: State) -> Bool {
                switch (lhs, rhs) {
                case (.loading, .loading),
                    (.appAccountsLoaded, .appAccountsLoaded),
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

        enum ActiveSheet: Identifiable {
            case assetsModal, paymentModal

            var id: Int {
                hashValue
            }
        }

        @Injected(\.appAccountsRepository) var appAccountsRepository
        @Injected(\.transactionsRespository) var transactionsRepository
        @Injected(\.assetsHelper) var assetHelper
        @Injected(\.flexaClient) var flexaClient
        @Injected(\.commerceSessionRepository) var commerceSessionRepository
        @Injected(\.assetConfig) var assetConfig
        @Injected(\.appStateManager) var appStateManager
        @Injected(\.flexcodeGenerator) var flexcodeGenerator
        @Injected(\.eventNotifier) var eventNotifier

        @Published var activeSheet: ActiveSheet?
        @Published var paymentCompleted = false
        @Published var paymentButtonEnabled = true
        @Published var appAccounts: [AppAccount] = []
        @Published var invalidUserAssets: [FXAvailableAsset] = []
        @Published var walletsWithSufficientBalance: [AppAccount] = []
        @Published var error: Error?
        @Published var flexCodes: [SpendCodeView.ViewModel] = []
        @Published var isShowingModal = false

        @Published var hideShortBalances: Bool = false {
            didSet {
                updateAppAccounts()
            }
        }

        @Published var showPaymentModal = false {
            didSet {
                activeSheet = showPaymentModal ? .paymentModal : nil
                updateModalState()
            }
        }

        @Published var showAssetsModal = false {
            didSet {
                if showPaymentModal {
                    activeSheet = (showAssetsModal) ? .assetsModal : nil
                }
                updateModalState()
            }
        }

        @Published var showManageFlexaAccountSheet = false

        @Published var showLegacyFlexcode = false {
            didSet {
                updateModalState()
            }
        }

        @Published var showInputAmountView = false {
            didSet {
                updateModalState()
            }
        }

        @Published var state = State.loading
        @Published var commerceSession: CommerceSession?

        var signTransaction: Flexa.TransactionRequestCallback?
        var selectedAsset: AssetWrapper?
        var sendTransactionWhenAvailable = false
        var legacyMode = false
        var legacyCommerceSessionIds: [String] = []
        var viewModelAsset: AssetSelectionViewModel!
        var transactionAmountViewModel: TransactionAmountView.ViewModel!

        var selectedAssetSymbol: String {
            selectedAsset?.assetSymbol ?? ""
        }

        var networkFee: String {
            ""
        }

        var amount: Decimal {
            commerceSession?.amount.decimalValue ?? 0
        }

        var baseAmountLabel: String {
            commerceSession?.requestedTransaction?.label ?? ""
        }

        var amountLabel: String {
            commerceSession?.label ?? commerceSession?.amount.asCurrency ?? ""
        }

        var merchantLogoUrl: URL? {
            commerceSession?.brand?.logoUrl
        }

        var merchantName: String {
            commerceSession?.brand?.name ?? ""
        }

        var showInvalidAssetMessage: Bool {
            if state == .loading {
                return false
            }
            return missingAppAccounts
        }

        var showLegacyFlexcodeList: Bool {
            state != .loading && !showInvalidAssetMessage
        }

        var missingAppAccounts: Bool {
            appAccounts.isEmpty || appAccounts.allSatisfy { $0.accountAssets.isEmpty }
        }

        var hasTransaction: Bool {
            commerceSession?.requestedTransaction != nil
        }

        required init(signTransaction: ((Result<FXTransaction, Error>) -> Void)?) {
            self.signTransaction = signTransaction

            viewModelAsset = AssetSelectionViewModel(
                walletsWithSufficientBalance,
                hideShortBalances,
                amount,
                selectedAsset)

            transactionAmountViewModel = TransactionAmountView.ViewModel(brand: nil)

            appAccounts = appAccountsRepository.appAccounts

            loadAppAccounts()
        }
    }
}

extension SpendView.ViewModel {
    private func updateModalState() {
        if #available(iOS 16, *) {
            isShowingModal = showPaymentModal || showLegacyFlexcode
        } else {
            isShowingModal = showPaymentModal || showAssetsModal || showLegacyFlexcode
        }
    }

    private func updateInvalidAssets() {
        let validAssetIds = appAccounts
            .map { $0.accountAssets }
            .joined()
            .filter { $0.decimalBalance > 0 && $0.assetKey != nil }
            .map { $0.assetId }

        invalidUserAssets = flexaClient.appAccounts
            .map { $0.availableAssets }
            .joined()
            .filter { !validAssetIds.contains($0.assetId) }
            .reduce(into: [FXAvailableAsset]()) { partialResult, fxAsset in
                if !partialResult.contains(where: { $0.assetId == fxAsset.assetId }) {
                    partialResult.append(fxAsset)
                }
            }
    }

    private func updateAppAccounts() {
        appAccounts = appAccountsRepository.appAccounts
        updateSelectAsset()

        if state == .loading {
            state = .appAccountsLoaded
        }

        if hideShortBalances {
            self.walletsWithSufficientBalance = appAccounts.filter { enoughWalletAmount($0) }
        } else {
            self.walletsWithSufficientBalance = appAccounts
        }

        flexCodes = appAccounts.reduce(into: [SpendCodeView.ViewModel]()) { partialResult, appAccount in
            partialResult.append(
                contentsOf: appAccount
                    .accountAssets
                    .map { SpendCodeView.ViewModel(asset: AssetWrapper(appAccount: appAccount, asset: $0)) }
            )
        }
        viewModelAsset.appAccounts = self.walletsWithSufficientBalance
        updateInvalidAssets()
        updateSelectedAsset()
    }

    func closeCommerceSession() {
        guard let id = commerceSession?.id else {
            return
        }
        self.commerceSession = nil

        Task {
            do {
                try await commerceSessionRepository.close(id)
            } catch let error {
                FlexaLogger.error(error)
            }
        }
    }

    func signAndSendLegacy(commerceSession: CommerceSession?) {
        legacyMode = commerceSession != nil
        if let id = commerceSession?.id {
            legacyCommerceSessionIds.append(id)
        }
        self.commerceSession = commerceSession
        state = .commerceSessionCreated
        signAndSend()
    }

    func signAndSend() {
        guard let commerceSession, let transaction = commerceSession.requestedTransaction else {
            paymentButtonEnabled = false
            FlexaLogger.error("Missing commerce session or transaction")
            return
        }

        DispatchQueue.main.async { [self] in
            appStateManager.addTransaction(commerceSessionId: commerceSession.id, transactionId: transaction.id ?? "")
            paymentButtonEnabled = false
            state = .transactionSent
            commerceSessionRepository.setCurrent(commerceSession, isLegacy: legacyMode, wasTransactionSent: true)
        }

        Task {
            signTransaction?(
                .success(
                    FXTransaction(
                        commerceSessionId: commerceSession.id,
                        amount: transaction.amount ?? "",
                        appAccountId: assetConfig.selectedAppAccountId,
                        assetId: assetConfig.selectedAssetId,
                        destinationAddress: transaction.destination?.address ?? "",
                        feeAmount: transaction.fee?.amount ?? "",
                        feeAssetId: transaction.fee?.asset ?? "",
                        feePrice: transaction.fee?.price.amount ?? "",
                        feePriorityPrice: transaction.fee?.price.priority,
                        size: transaction.size,
                        brandLogo: commerceSession.brand?.logoUrl?.absoluteString,
                        brandName: commerceSession.brand?.name,
                        brandColor: commerceSession.brand?.color?.hex
                    )
                )
            )
        }
    }

    func updateSelectedAsset() {
        appAccountsRepository.sanitizeSelectedAsset()

        guard let appAccount = appAccounts.first(where: { $0.accountId == assetConfig.selectedAppAccountId }),
              let asset = appAccount.accountAssets.first(where: { $0.assetId == assetConfig.selectedAssetId }) else {
            return
        }

        selectedAsset = AssetWrapper(appAccount: appAccount, asset: asset)
        viewModelAsset.selectedAsset = selectedAsset

        if !transactionAmountViewModel.isLoading {
            transactionAmountViewModel.selectedAsset = selectedAsset
        }
    }

    func updateSelectAsset() {
        guard let selectedAsset = selectedAsset else {
            return
        }
        updateAsset(selectedAsset)
    }

    func updateAsset(_ selectedAsset: AssetWrapper) {
        self.selectedAsset = selectedAsset
        assetConfig.selectedAppAccountId = selectedAsset.appAccount.accountId
        assetConfig.selectedAssetId = selectedAsset.asset.assetId
        paymentButtonEnabled = state != .transactionSent && enoughAmount(selectedAsset.asset)
        updateCommerceSessionAsset()
    }

    func enoughWalletAmount(_ appAccount: AppAccount) -> Bool {
        appAccount.accountAssets.contains { enoughAmount($0) }
    }

    func enoughAmount(_ asset: AppAccountAsset) -> Bool {
        asset.decimalBalance >= amount
    }

    func clear() {
        legacyMode = false
        paymentCompleted = false
        showLegacyFlexcode = false
        showPaymentModal = false
        closeCommerceSession()
        state = .appAccountsLoaded
    }

    func clearIfAuthorizationIsPending() {
        guard commerceSession?.authorization == nil else {
            return
        }
        clear()
    }

    func loadAppAccounts() {
        appAccounts = appAccountsRepository.appAccounts
        if !appAccounts.isEmpty {
            updateAppAccounts()
        }
        Task {
            let appAccounts = try? await appAccountsRepository.refresh()
            if appAccounts != nil {
                handleAppAccountsDidUpdate()
            }
        }
    }

    func startWatching() {
        Task {
            do {
                let current = try await commerceSessionRepository.getCurrent()
                await resumeCommerceSession(
                    current.commerceSession,
                    isLegacy: current.isLegacy,
                    wasTransactionSent: current.wasTransactionSent
                )
            } catch let error {
                FlexaLogger.error(error)
                commerceSessionRepository.clearCurrent()
            }

            eventNotifier.addObserver(self, selector: #selector(handleAppAccountsDidUpdate), name: .appAccountsDidUpdate)
            commerceSessionRepository.watch(currentOnly: true) { [weak self] result in
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .success(let event):
                        self?.handleCommerceSessionEvent(event)
                    case .failure(let error):
                        FlexaLogger.error(error)
                    }
                }
            }
        }

    }

    func stopWatching() {
        commerceSessionRepository.stopWatching()
    }
}

private extension SpendView.ViewModel {
    @MainActor
    func resumeCommerceSession(_ commerceSession: CommerceSession?, isLegacy: Bool, wasTransactionSent: Bool) {

        // If there is not a commerce session or is closed then just clear the current commerce session
        guard let commerceSession, !commerceSession.isClosed else {
            commerceSessionRepository.clearCurrent()
            return
        }

        var event = CommerceSessionEvent.created(commerceSession)

        // Check completion for next gen, we need to display the success card
        if isLegacy {
            self.legacyCommerceSessionIds.append(commerceSession.id)
        } else if commerceSession.isCompleted {
            event = .completed(commerceSession)
        }

        // If the transaction was already sent, then we should display the CommerceSession's transaction
        if wasTransactionSent {
            let appAccount = flexaClient.appAccounts
                .first(where:
                        { $0.availableAssets.contains(where: { $0.assetId == commerceSession.preferences.paymentAsset })
                })

            if let appAccount {
                assetConfig.selectedAppAccountId = appAccount.accountId
                assetConfig.selectedAssetId = commerceSession.preferences.paymentAsset
                selectedAsset = AssetWrapper(appAccountId: appAccount.accountId, assetId: commerceSession.preferences.paymentAsset)
                viewModelAsset.selectedAsset = selectedAsset
            }
        }

        // Set state
        self.state = wasTransactionSent ? .transactionSent : .commerceSessionCreated
        self.commerceSession = commerceSession
        self.legacyMode = isLegacy
        self.handleCommerceSessionEvent(event)

        // Patch CommerceSession's asset if we need to
        if !isLegacy && !wasTransactionSent {
            updateCommerceSessionAsset()
        }
    }

    @objc func handleAppAccountsDidUpdate() {
        Task {
            await MainActor.run {
                updateAppAccounts()
            }
        }
    }

    func updateCommerceSessionAsset() {
        guard let id = commerceSession?.id,
              let assetId = selectedAsset?.assetId,
              let paymentAssetId = commerceSession?.preferences.paymentAsset,
              assetId != paymentAssetId,
              paymentButtonEnabled,
              !legacyMode else {
            return
        }
        self.paymentButtonEnabled = false

        Task {
            do {
                try await commerceSessionRepository.setPaymentAsset(commerceSessionId: id, assetId: assetId)
                await MainActor.run {
                    paymentButtonEnabled = true
                }
            } catch let error {
                await MainActor.run {
                    FlexaLogger.error(error)
                    let newAppAccount = walletsWithSufficientBalance.first { appAccount in
                        appAccount.accountAssets.contains(where: { $0.assetId == paymentAssetId })
                    }
                    let newAsset = newAppAccount?.accountAssets.first { $0.assetId == paymentAssetId }
                    if let newAppAccount, let newAsset {
                        updateAsset(AssetWrapper(appAccount: newAppAccount, asset: newAsset))
                    }

                    paymentButtonEnabled = true
                }
            }
        }
    }

    func handleCommerceSessionEvent(_ event: CommerceSessionEvent) {
        if legacyMode {
            handleLegacyFlexcodeCommerceSessionEvent(event)
        } else if !legacyCommerceSessionIds.contains(event.commerceSession.id) {
            handleNextGenFlexcodeCommerceSessionEvent(event)
        }
    }

    func handleNextGenFlexcodeCommerceSessionEvent(_ event: CommerceSessionEvent) {
        switch event {
        case .created(let commerceSession):
            if !showPaymentModal {
                self.commerceSession = commerceSession
                showPaymentModal = true

                if state != .transactionSent {
                    state = .commerceSessionCreated
                }

                paymentButtonEnabled = state == .commerceSessionCreated

                if let selectedAsset, selectedAsset.assetId != commerceSession.preferences.paymentAsset {
                    updateCommerceSessionAsset()
                }
            }
            commerceSessionRepository.setCurrent(commerceSession, isLegacy: false, wasTransactionSent: state == .transactionSent)
        case .updated(let commerceSession):
            guard !commerceSession.isClosed else {
                commerceSessionRepository.clearCurrent()
                return
            }

            if state == .commerceSessionCreated {
                state = .commerceSessionUpdated
            }

            self.commerceSession = commerceSession
            showPaymentModal = true

            if !paymentButtonEnabled, hasTransaction {
                signAndSend()
            }
        case .completed(let commerceSession):
            self.commerceSession = commerceSession
            state = .commerceSessionCompleted
            showPaymentModal = true
            paymentCompleted = true
            commerceSessionRepository.clearCurrent()
        }
    }

    func handleLegacyFlexcodeCommerceSessionEvent(_ event: CommerceSessionEvent) {
        switch event {
        case .created(let commerceSession):
            if showInputAmountView {
                if !commerceSession.transactions.isEmpty || commerceSession.authorization != nil {
                    self.commerceSession = commerceSession
                }
            } else {
                self.commerceSession = commerceSession
                transactionAmountViewModel.setCommerceSession(commerceSession)
                showInputAmountView = commerceSession.authorization == nil
            }

            commerceSessionRepository.setCurrent(commerceSession, isLegacy: true, wasTransactionSent: true)
        case .updated(let commerceSession):
            guard !commerceSession.isClosed else {
                commerceSessionRepository.clearCurrent()
                return
            }

            if state == .commerceSessionCreated {
                state = .commerceSessionUpdated
            }

            if !commerceSession.transactions.isEmpty || commerceSession.authorization != nil {
                self.commerceSession = commerceSession
            }
            commerceSessionRepository.setCurrent(commerceSession, isLegacy: true, wasTransactionSent: true)
        case .completed(let commerceSession):
            self.commerceSession = commerceSession
            state = .commerceSessionCompleted
            paymentCompleted = true
        }

        showLegacyFlexcodeCardIfNeeded()
    }

    func showLegacyFlexcodeCardIfNeeded() {
        guard legacyMode, commerceSession?.authorization != nil else {
            return
        }

        showInputAmountView = false
        showLegacyFlexcode = true
    }
}
