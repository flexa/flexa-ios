//
//  CommerceSessionViewModel.swift
//  FlexaCore
//
//  Created by Juan Olivera on 1/16/25.
//

import Foundation
import SwiftUI
import Factory

public extension CommerceSessionView {
    class ViewModel: ObservableObject, Identifiable {
        @Injected(\.flexaClient) var flexaClient
        @Injected(\.assetConfig) public var assetConfig
        @Injected(\.oneTimeKeysRepository) var oneTimeKeysRepository
        @Injected(\.exchangeRatesRepository) var exchangeRatesRepository
        @Injected(\.accountRepository) var accountRepository
        @Injected(\.commerceSessionRepository) public var commerceSessionRepository
        @Injected(\.eventNotifier) var eventNotifier

        @Published var loadingTitle = ""
        @Published var paymentButtonEnabled = true
        @Published var paymentCompleted = false
        @Published var assetSwitcherEnabled = true
        @Published public var isShowingModal = false
        @Published public var accounts: [AssetAccount] = []
        @Published public var transactionAmountViewModel: TransactionAmountView.ViewModel
        @Published public var viewModelAsset: AssetSelectionViewModel
        @Published public var error: EquatableError?

        @Published public var commerceSessionHandler: CommerceSessionHandler
        var fromPaymentLink = false
        var isStandalone = false

        @Published var showPaymentModal = false {
            didSet {
                updateModalState()
            }
        }

        @Published var showLegacyFlexcode = false {
            didSet {
                updateModalState()
            }
        }

        @Published public var showInputAmountView = false {
            didSet {
                updateModalState()
            }
        }

        @Published public var showAssetsModal = false {
            didSet {
                updateModalState()
            }
        }

        public var selectedAsset: AssetWrapper? {
            commerceSessionHandler.selectedAsset
        }

        public var commerceSession: CommerceSession? {
            commerceSessionHandler.commerceSession
        }

        public var amount: Decimal {
            commerceSession?.amount.decimalValue ?? 0
        }

        public var baseAmountLabel: String {
            commerceSession?.requestedTransaction?.label ?? ""
        }

        public var amountLabel: String {
            commerceSession?.label ??
            commerceSession?.amount.asCurrency ?? ""
        }

        public var merchantLogoUrl: URL? {
            commerceSession?.brand?.logoUrl
        }

        public var merchantName: String {
            commerceSession?.brand?.name ?? ""
        }

        public var merchantColor: Color? {
            commerceSession?.brand?.color
        }

        public var isUsingAccountBalance: Bool {
            commerceSessionHandler.isUsingAccountBalance
        }

        public var transactionSent: Bool {
            commerceSessionHandler.state == .transactionSent ||
            commerceSessionHandler.state == .commerceSessionCompleted
        }

        public var fee: Fee? {
            commerceSessionHandler.commerceSession?.requestedTransaction?.fee
        }

        var hasTransaction: Bool {
            commerceSession?.requestedTransaction != nil
        }

        private var requiresApprovalOnly: Bool {
            commerceSession?.status == .requiresApproval
        }

        public required init(
            signTransaction: ((Result<FXTransaction, Error>) -> Void)?,
            isStandalone: Bool = false) {
                self.isStandalone = isStandalone
                let accounts = Container.shared.flexaClient().availableAssetAccounts
                let viewModelAsset = AssetSelectionViewModel(
                    accounts,
                    0,
                    nil
                )
                let transactionAmountViewModel = TransactionAmountView.ViewModel(brand: nil)

                self.accounts = accounts
                self.viewModelAsset = viewModelAsset
                self.transactionAmountViewModel = transactionAmountViewModel
                self.commerceSessionHandler = CommerceSessionHandler(signTransaction: signTransaction,
                                                                     selectedAsset: viewModelAsset.selectedAsset)
                self.transactionAmountViewModel = transactionAmountViewModel
                updateSelectedAsset()
                eventNotifier.addObserver(self, selector: #selector(handleAccountsDidUpdate), name: .assetAccountsDidChange)
        }

        deinit {
            eventNotifier.removeObserver(self)
        }

        public func createCommerceSession(_ url: URL) async throws -> CommerceSession? {
            fromPaymentLink = true
            return try await commerceSessionHandler.createCommerceSession(url)
        }

        public func startWatching() {
            commerceSessionHandler.startWatching()
        }

        public func stopWatching() {
            commerceSessionHandler.stopWatching()
        }

        public func brandSelected(_ brand: Brand?) {
            transactionAmountViewModel.clear()
            transactionAmountViewModel.brand = brand
            transactionAmountViewModel.selectedAsset = viewModelAsset.selectedAsset
            updateSelectedAsset()
            if let selectedAsset = selectedAsset {
                updateAsset(selectedAsset)
            }
            showInputAmountView = true
        }

        public func clear() {
            commerceSessionHandler.clear()
            showInputAmountView = false
            showLegacyFlexcode = false
            showPaymentModal = false
            fromPaymentLink = false
        }

        public func updateAsset(_ selectedAsset: AssetWrapper) {
            commerceSessionHandler.updateAsset(selectedAsset)
        }

        public func sendNextGen() {
            performCommerceSessionAction {
                try await self.commerceSessionHandler.sendNextGen()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard let self, self.loadingTitle.isEmpty else {
                        return
                    }
                    setLoadingButtonTitle(CoreStrings.Global.signing)
                }
            }
        }

        public func sendLegacy(commerceSession: CommerceSession?) {
            performCommerceSessionAction {
                try await self.commerceSessionHandler.sendLegacy(commerceSession: commerceSession)
            }
        }

        public func clear(canceled: Bool) {
            commerceSessionHandler.clear(canceled: canceled)
        }

        public func approveAndSend(commerceSession: CommerceSession) {
            performCommerceSessionAction {
                try await self.commerceSessionHandler.approveAndSend(commerceSession)
            }
        }

        public func signAndSend(commerceSession: CommerceSession) {
            performCommerceSessionAction {
                await self.commerceSessionHandler.signAndSend(commerceSession)
            }
        }

        public func updateSelectAsset() {
            let selectedAsset = AssetWrapper(
                accountHash: assetConfig.selectedAssetAccountHash,
                assetId: assetConfig.selectedAssetId
            )
            commerceSessionHandler.updateAsset(selectedAsset)
        }

        public func clearIfAuthorizationIsPending(canceled: Bool = false) {
            guard commerceSessionHandler.commerceSession?.authorization == nil else {
                return
            }
            commerceSessionHandler.clear(canceled: canceled)
        }

        public func closeCommerceSession() {
            commerceSessionHandler.closeCommerceSession()
        }

        private func updateModalState() {
            var isShowingModal = showPaymentModal || showLegacyFlexcode || showInputAmountView
            if #unavailable(iOS 16) {
                isShowingModal = isShowingModal || showAssetsModal
            }
            self.isShowingModal = isShowingModal
        }

        func transactionSentHandler() {
            Task {
                await setLoadingButtonTitle(CoreStrings.Global.sending)
            }
        }

        @MainActor
        func setLoadingButtonTitle(_ title: String) {
            self.loadingTitle = title
        }

        @objc func handleAccountsDidUpdate() {
            Task {
                await MainActor.run {
                    updateAccounts()
                }
            }
        }

        func updateAccounts() {
            accounts = flexaClient.availableAssetAccounts
            viewModelAsset.assetAccounts = accounts
            updateSelectedAsset()
        }

        @MainActor
        func handlePaymentCompletedChange(_ completed: Bool) {
            paymentCompleted = completed
            if fromPaymentLink || !commerceSessionHandler.legacyMode {
                showInputAmountView = false
            } else {
                showInputAmountView = false
                showLegacyFlexcode = true
            }
        }

        @MainActor
        func handlePaymentEnabledChange(_ enabled: Bool) {
            paymentButtonEnabled = enabled
        }

        @MainActor
        func handleTransactionInProgressChange(_ enabled: Bool) {
            paymentButtonEnabled = enabled
        }

        @MainActor
        func handleStateChange(_ value: CommerceSessionHandler.State) {
            if value == .commerceSessionCreated || value == .transactionSent || value == .commerceSessionRequiresAmount {
                if commerceSessionHandler.legacyMode || value == .commerceSessionRequiresAmount {
                    if let commerceSession {
                        transactionAmountViewModel.setCommerceSession(commerceSession, transactionSent: value == .transactionSent)
                    }
                    showInputAmountView = true
                } else {
                    showPaymentModal = true
                }
            }

            if value == .commerceSessionCompleted && !commerceSessionHandler.legacyMode {
                paymentCompleted = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    if self.isStandalone {
                        Flexa.close()
                    } else {
                        self.showPaymentModal = false
                    }
                }
            }
        }

        @MainActor
        func setError(_ error: Error?) {
            guard let error else {
                self.error = nil
                return
            }
            self.error = EquatableError(error)
        }

        func performCommerceSessionAction(action: (() async throws -> Void)?) {
            Task {
                do {
                    try await action?()
                } catch let error {
                    await setError(error)
                }
            }
        }

        public func updateSelectedAsset() {
            flexaClient.sanitizeSelectedAsset()

            guard let account = accounts.first(where: { $0.id == assetConfig.selectedAssetAccountHash }),
                  let asset = account.assets.first(where: { $0.assetId == assetConfig.selectedAssetId }) else {
                return
            }

            viewModelAsset.selectedAsset = AssetWrapper(accountHash: account.id, assetId: asset.assetId)
            commerceSessionHandler.selectedAsset = viewModelAsset.selectedAsset

            if !transactionAmountViewModel.isLoading, transactionAmountViewModel.selectedAsset != selectedAsset {
                transactionAmountViewModel.selectedAsset = selectedAsset
            }
        }
    }
}
