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

        enum ActiveSheet: Identifiable {
            case assetsModal, paymentModal

            var id: Int {
                hashValue
            }
        }

        @Injected(\.transactionsRespository) var transactionsRepository
        @Injected(\.flexaClient) var flexaClient
        @Injected(\.commerceSessionRepository) var commerceSessionRepository
        @Injected(\.assetConfig) var assetConfig
        @Injected(\.appStateManager) var appStateManager
        @Injected(\.flexcodeGenerator) var flexcodeGenerator
        @Injected(\.eventNotifier) var eventNotifier
        @Injected(\.exchangeRatesRepository) var exchangeRatesRepository
        @Injected(\.oneTimeKeysRepository) var oneTimeKeysRepository
        @Injected(\.assetsRepository) var assetsRepository
        @Injected(\.transactionFeesRepository) var transactionFeesRepository
        @Injected(\.urlRouter) var urlRouter

        @Published var activeSheet: ActiveSheet?
        @Published var paymentCompleted = false
        @Published var paymentButtonEnabled = true
        @Published var assetSwitcherEnabled = true
        @Published var accounts: [AssetAccount] = []
        @Published var invalidUserAssets: [FXAvailableAsset] = []
        @Published var walletsWithSufficientBalance: [AssetAccount] = []
        @Published var error: Error?
        @Published var flexCodes: [SpendCodeView.ViewModel] = []
        @Published var isShowingModal = false
        @Published var isShowingWebView = false

        @Published var hideShortBalances: Bool = false {
            didSet {
                updateAccounts()
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

        @Synchronized var isUpdatingPaymentAsset = false

        var signTransaction: Flexa.TransactionRequestCallback?
        var selectedAsset: AssetWrapper?
        var sendTransactionWhenAvailable = false
        var legacyMode = false
        var legacyCommerceSessionIds: [String] = []
        var viewModelAsset: AssetSelectionViewModel!
        var transactionAmountViewModel: TransactionAmountView.ViewModel!
        var url: URL?

        var selectedAssetSymbol: String {
            selectedAsset?.assetSymbol ?? ""
        }

        var fee: Fee? {
            commerceSession?.requestedTransaction?.fee
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
            setAccounts()
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
        setAccounts()
        updateSelectAsset()

        if state == .loading {
            state = .accountsLoaded
        }

        if hideShortBalances {
            self.walletsWithSufficientBalance = accounts.filter { enoughWalletAmount($0) }
        } else {
            self.walletsWithSufficientBalance = accounts
        }

        flexCodes = accounts.reduce(into: [SpendCodeView.ViewModel]()) { partialResult, account in
            partialResult.append(
                contentsOf: account
                    .assets
                    .map { SpendCodeView.ViewModel(asset: $0) }
            )
        }
        viewModelAsset.assetAccounts = self.walletsWithSufficientBalance
        updateInvalidAssets()
        updateSelectedAsset()
    }

    func closeCommerceSession() {
        guard let commerceSession = self.commerceSession else {
            return
        }

        self.commerceSession = nil

        if !legacyMode && commerceSession.isCompleted {
            return
        }

        Task {
            do {
                try await commerceSessionRepository.close(commerceSession.id)
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
            assetSwitcherEnabled = false
            FlexaLogger.error("Missing commerce session or transaction")
            return
        }

        guard state != .transactionSent else {
            return
        }

        DispatchQueue.main.async { [self] in
            appStateManager.addTransaction(commerceSessionId: commerceSession.id, transactionId: transaction.id ?? "")
            paymentButtonEnabled = false
            assetSwitcherEnabled = false
            state = .transactionSent
            commerceSessionRepository.setCurrent(commerceSession, isLegacy: legacyMode, wasTransactionSent: true)
        }

        Task {
            signTransaction?(
                .success(
                    FXTransaction(
                        commerceSessionId: commerceSession.id,
                        amount: transaction.amount ?? "",
                        assetAccountHash: assetConfig.selectedAssetAccountHash,
                        assetId: assetConfig.selectedAssetId,
                        destinationAddress: transaction.destination?.address ?? "",
                        feeAmount: transaction.fee?.amount ?? "",
                        feeAssetId: transaction.fee?.asset ?? "",
                        feePrice: transaction.fee?.price?.amount ?? "",
                        feePriorityPrice: transaction.fee?.price?.priority ?? "",
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
        flexaClient.sanitizeSelectedAsset()

        guard let account = accounts.first(where: { $0.id == assetConfig.selectedAssetAccountHash }),
              let asset = account.assets.first(where: { $0.assetId == assetConfig.selectedAssetId }) else {
            return
        }

        selectedAsset = AssetWrapper(accountHash: account.id, assetId: asset.assetId)
        viewModelAsset.selectedAsset = selectedAsset

        if !transactionAmountViewModel.isLoading, transactionAmountViewModel.selectedAsset != selectedAsset {
            transactionAmountViewModel.selectedAsset = selectedAsset
        }
    }

    func updateSelectAsset() {
        let selectedAsset = AssetWrapper(
            accountHash: assetConfig.selectedAssetAccountHash,
            assetId: assetConfig.selectedAssetId
        )
        updateAsset(selectedAsset)
    }

    func updateAsset(_ selectedAsset: AssetWrapper) {
        self.selectedAsset = selectedAsset
        assetConfig.selectedAssetAccountHash = selectedAsset.accountId
        assetConfig.selectedAssetId = selectedAsset.assetId
        paymentButtonEnabled = state != .transactionSent && selectedAsset.enoughBalance(for: amount)
        updateCommerceSessionAsset()
    }

    func enoughWalletAmount(_ account: AssetAccount) -> Bool {
        account.assets.contains { enoughAmount($0) }
    }

    func enoughAmount(_ asset: AssetWrapper) -> Bool {
        asset.balance >= amount
    }

    func clear() {
        closeCommerceSession()
        legacyMode = false
        paymentCompleted = false
        showLegacyFlexcode = false
        showPaymentModal = false
        isUpdatingPaymentAsset = false
        state = .accountsLoaded
    }

    func clearIfAuthorizationIsPending() {
        guard commerceSession?.authorization == nil else {
            return
        }
        clear()
    }

    func setAccounts() {
        self.accounts = flexaClient.availableAssetAccounts
    }

    func loadAccounts() {
        setAccounts()
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

    func startWatching() {
        exchangeRatesRepository.backgroundRefresh()
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

            eventNotifier.addObserver(self, selector: #selector(handleAccountsDidUpdate), name: .oneTimeKeysDidUpdate)
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
        eventNotifier.removeObserver(self)
        commerceSessionRepository.stopWatching()
    }

    func handleUrl(url: URL) -> Bool {
        let link = urlRouter.getLink(from: url)
        switch link {
        case .account:
            showManageFlexaAccountSheet = true
            return true
        case .webView(let url):
            self.url = url
            isShowingWebView = true
            return true
        case .systemBrowser(let url):
            self.url = url
            return false
        default:
            self.url = url
            return false
        }
    }

    func refreshFlexcodes() {
        flexCodes.forEach { $0.updateIfNeeded() }
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
            let account = flexaClient.assetAccounts
                .first(where:
                        { $0.availableAssets.contains(where: { $0.assetId == commerceSession.preferences.paymentAsset })
                })

            if let account {
                assetConfig.selectedAssetAccountHash = account.assetAccountHash
                assetConfig.selectedAssetId = commerceSession.preferences.paymentAsset
                selectedAsset = AssetWrapper(accountHash: account.assetAccountHash, assetId: commerceSession.preferences.paymentAsset)
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

    @objc func handleAccountsDidUpdate() {
        Task {
            do {
                try await exchangeRatesRepository.refresh()
            } catch let error {
                FlexaLogger.error(error)
            }
            await MainActor.run {
                updateAccounts()
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

        self.isUpdatingPaymentAsset = true
        self.paymentButtonEnabled = false

        Task {
            do {
                try await commerceSessionRepository.setPaymentAsset(commerceSessionId: id, assetId: assetId)
                await MainActor.run {
                    isUpdatingPaymentAsset = false
                    paymentButtonEnabled = true
                    assetSwitcherEnabled = true
                }
            } catch let error {
                await MainActor.run {
                    FlexaLogger.error(error)
                    let newAccount = walletsWithSufficientBalance.first { account in
                        account.assets.contains(where: { $0.assetId == paymentAssetId })
                    }
                    let newAsset = newAccount?.assets.first { $0.assetId == paymentAssetId }
                    if let newAccount, let newAsset {
                        updateAsset(AssetWrapper(accountHash: newAccount.id, assetId: newAsset.assetId))
                    }

                    paymentButtonEnabled = true
                    assetSwitcherEnabled = true
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

                if state == .commerceSessionCreated {
                    paymentButtonEnabled = selectedAsset?.enoughBalance(for: amount) ?? true
                }

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

            if !paymentButtonEnabled, !isUpdatingPaymentAsset, hasTransaction, state != .transactionSent {
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
