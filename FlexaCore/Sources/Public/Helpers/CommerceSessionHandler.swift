//
//  CommerceSessionHandler.swift
//  FlexaCore
//
//  Created by Juan Olivera on 12/20/24.
//
import Combine
import Foundation
import Factory
import SwiftUI

enum TransactionError: Error {
    case failedTransactionApproval(String)
}

public extension CommerceSessionHandler {
    enum State: Equatable {
        case loading
        case accountsLoaded
        case commerceSessionCreated
        case commerceSessionRequiresTransaction
        case commerceSessionRequiresAmount
        case commerceSessionRequiresApproval
        case transactionSent
        case commerceSessionCompleted
        case commerceSessionClosed
        case error(Error)

        public static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading),
                (.accountsLoaded, .accountsLoaded),
                (.commerceSessionCreated, .commerceSessionCreated),
                (.transactionSent, .transactionSent),
                (.commerceSessionCompleted, .commerceSessionCompleted),
                (.commerceSessionRequiresTransaction, .commerceSessionRequiresTransaction),
                (.commerceSessionRequiresApproval, .commerceSessionRequiresApproval),
                (.commerceSessionRequiresAmount, .commerceSessionRequiresAmount):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
}

public class CommerceSessionHandler: ObservableObject {
    @Injected(\.commerceSessionRepository) var commerceSessionRepository
    @Injected(\.exchangeRatesRepository) var exchangeRatesRepository
    @Injected(\.accountRepository) var accountRepository
    @Injected(\.assetConfig) var assetConfig
    @Injected(\.flexaClient) var flexaClient
    @Injected(\.eventNotifier) var eventNotifier
    @Injected(\.appStateManager) var appStateManager

    @Published public var commerceSession: CommerceSession?
    @Published public var state = State.loading
    @Published public var paymentCompleted = false

    @Published var walletsWithSufficientBalance: [AssetAccount] = []
    @Published var transactionIsInProgress = false
    @Published var paymentEnabled = false

    public var legacyMode = false
    public var selectedAsset: AssetWrapper?
    public var signTransaction: Flexa.TransactionRequestCallback?
    public var onPaymentAuthorization: Flexa.PaymentAuthorizationCallback?

    var legacyCommerceSessionIds: [String] = []
    var sendTransactionWhenAvailable = false
    var viewModelAsset: AssetSelectionViewModel!

    var amount: Decimal {
        commerceSession?.amount.decimalValue ?? 0
    }

    var hasTransaction: Bool {
        commerceSession?.requestedTransaction != nil
    }

    var isUsingAccountBalance: Bool {
        commerceSession?.status == .requiresApproval
    }

    private var requiresApprovalOnly: Bool {
        commerceSession?.status == .requiresApproval
    }

    @Synchronized var isUpdatingPaymentAsset = false

    public init(signTransaction: Flexa.TransactionRequestCallback?, selectedAsset: AssetWrapper?) {
        self.signTransaction = signTransaction
        self.selectedAsset = selectedAsset
    }

    func startWatching() {
        exchangeRatesRepository.backgroundRefresh()
        accountRepository.backgroundRefresh()
        Task {
            do {
                let current = try await commerceSessionRepository.getCurrent()
                legacyMode = current.isLegacy
                await resumeCommerceSession(
                    current.commerceSession,
                    isLegacy: legacyMode,
                    wasTransactionSent: current.wasTransactionSent
                )
            } catch let error {
                FlexaLogger.error(error)
                commerceSessionRepository.clearCurrent()
            }

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

    public func updateAsset(_ selectedAsset: AssetWrapper) {
        self.selectedAsset = selectedAsset
        assetConfig.selectedAssetAccountHash = selectedAsset.accountId
        assetConfig.selectedAssetId = selectedAsset.assetId
        updateCommerceSessionAsset()
    }

    func updateCommerceSessionAsset() {
        guard let commerceSession else {
            return
        }

        let paymentAssetId = commerceSession.preferences.paymentAsset

        guard let assetId = selectedAsset?.assetId,
              assetId != paymentAssetId,
              !commerceSession.requiresApproval,
              !legacyMode else {
            return
        }

        self.isUpdatingPaymentAsset = true
        self.paymentEnabled = false

        Task {
            do {
                try await commerceSessionRepository.setPaymentAsset(
                    commerceSessionId: commerceSession.id,
                    assetId: assetId
                )
                await MainActor.run {
                    isUpdatingPaymentAsset = false
                    paymentEnabled = true
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
                    paymentEnabled = true
                }
            }
        }
    }

    // MARK: Handle Commerce session event
    func handleCommerceSessionEvent(_ event: CommerceSessionEvent) {
        if legacyMode {
            handleLegacyFlexcodeCommerceSessionEvent(event)
        } else if !legacyCommerceSessionIds.contains(event.commerceSession.id) {
            handleNextGenFlexcodeCommerceSessionEvent(event)
        }
    }

    func handleLegacyFlexcodeCommerceSessionEvent(_ event: CommerceSessionEvent) {
        switch event {
        case .created(let commerceSession):
            commerceSessionRepository.setCurrent(commerceSession, isLegacy: true, wasTransactionSent: true)
        case .requiresTransaction(let commerceSession),
                .requiresApproval(let commerceSession),
                .requiresAmount(let commerceSession):

            state = getStateFromEvent(event)
            if !commerceSession.transactions.isEmpty || commerceSession.authorization != nil {
                self.commerceSession = commerceSession
            }
            commerceSessionRepository.setCurrent(commerceSession, isLegacy: true, wasTransactionSent: true)
        case .completed(let commerceSession):
            self.commerceSession = commerceSession
            DispatchQueue.main.async { [self] in
                state = .commerceSessionCompleted
                paymentCompleted = true
            }
        case .closed:
            clear()
            return
        }

        guard legacyMode, commerceSession?.authorization != nil else {
            return
        }
        commerceSessionRepository.clearCurrent()
        paymentCompleted = true
    }

    func handleNextGenFlexcodeCommerceSessionEvent(_ event: CommerceSessionEvent) {
        switch event {
        case .created(let commerceSession):
            if state != .transactionSent {
                state = .commerceSessionCreated
            }
            self.commerceSession = commerceSession
            if let selectedAsset, selectedAsset.assetId != commerceSession.preferences.paymentAsset {
                updateCommerceSessionAsset()
            }

            commerceSessionRepository.setCurrent(commerceSession,
                                                 isLegacy: false,
                                                 wasTransactionSent: state == .transactionSent)
        case .requiresTransaction(let commerceSession),
                .requiresApproval(let commerceSession),
                .requiresAmount(let commerceSession):

            if state != .transactionSent {
                state = getStateFromEvent(event)
            }

            self.commerceSession = commerceSession

            if sendTransactionWhenAvailable, !isUpdatingPaymentAsset, hasTransaction, state != .transactionSent {
                Task {
                    do {
                        try await sendNextGen()
                    } catch let error {
                        // TODO:
                    }
                }
            }
        case .completed(let commerceSession):
            self.commerceSession = commerceSession
            state = .commerceSessionCompleted
            paymentCompleted = true
            commerceSessionRepository.clearCurrent()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.clear()
            }
        case .closed:
            clear()
        }
    }

    // MARK: Commerce session lifecycle
    func createCommerceSession(_ url: URL) async throws -> CommerceSession? {
        guard let paymentAsset = selectedAsset?.assetId else {
            FlexaLogger.info("Discarding payment link because there is a not a a selected asset")
            return nil
        }

        DispatchQueue.main.async {
            self.clear()
        }
        let commerceSession = try await commerceSessionRepository.create(
            paymentLink: url,
            paymentAssetId: paymentAsset
        )
        let event = CommerceSessionEvent.created(commerceSession)
        DispatchQueue.main.async {
            self.handleNextGenFlexcodeCommerceSessionEvent(event)
        }

        return commerceSession
    }

    func closeCommerceSession() {
        guard let commerceSession = self.commerceSession else {
            return
        }

        self.commerceSession = nil

        if !legacyMode && commerceSession.isCompleted {
            return
        }

        DispatchQueue.main.async {
            self.state = .commerceSessionClosed
        }

        Task {
            do {
                let closedCommerceSession = try await commerceSessionRepository.close(commerceSession.id)
                notifyPaymentAuthorizationChange(closedCommerceSession)
            } catch let error {
                FlexaLogger.error(error)
            }
        }
    }

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
        } else if wasTransactionSent {
            transactionIsInProgress = true
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
                selectedAsset = AssetWrapper(accountHash: account.assetAccountHash,
                                             assetId: commerceSession.preferences.paymentAsset)
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

    // MARK: Transactions
    func sendNextGen() async throws {
        guard let commerceSession else {
            FlexaLogger.commerceSessionLogger.error("Missing commerce session")
            return
        }

        guard state != .transactionSent else {
            return
        }

        if requiresApprovalOnly {
            try await approveAndSend(commerceSession)
        } else {
            await signAndSend(commerceSession)
        }
    }

    func sendLegacy(commerceSession: CommerceSession?) async throws {
        legacyMode = commerceSession != nil
        if let id = commerceSession?.id {
            legacyCommerceSessionIds.append(id)
        }

        await MainActor.run {
            self.commerceSession = commerceSession
            state = .commerceSessionCreated
        }

        guard let commerceSession else {
            FlexaLogger.commerceSessionLogger.error("Missing commerce session")
            return
        }

        guard state != .transactionSent else {
            return
        }

        if requiresApprovalOnly {
            await try approveAndSend(commerceSession)
        } else {
            await signAndSend(commerceSession)
        }
    }

    func approveAndSend(_ commerceSession: CommerceSession) async throws {
        try await approveTransaction(commerceSession)

        DispatchQueue.main.async { [self] in
            state = .transactionSent
            commerceSessionRepository.setCurrent(commerceSession, isLegacy: legacyMode, wasTransactionSent: false)
        }
    }

    func signAndSend(_ commerceSession: CommerceSession) async {
        guard let transaction = commerceSession.requestedTransaction else {
            paymentEnabled = false
            sendTransactionWhenAvailable = true
            FlexaLogger.commerceSessionLogger.error("Missing commerce session or transaction")
            return
        }

        guard state != .transactionSent else {
            return
        }

        DispatchQueue.main.async { [self] in
            appStateManager.addTransaction(commerceSessionId: commerceSession.id, transactionId: transaction.id ?? "")
            state = .transactionSent
            paymentEnabled = false
            commerceSessionRepository.setCurrent(commerceSession, isLegacy: legacyMode, wasTransactionSent: true)
        }

        Task {
            FlexaLogger.commerceSessionLogger.debug("Send transaction to parent application")
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

    func approveTransaction(_ commerceSession: CommerceSession) async throws {
        guard commerceSession.status == .requiresApproval else {
            return
        }
        try await commerceSessionRepository.approve(commerceSession.id)
        accountRepository.backgroundRefresh()
    }

    func getStateFromEvent(_ event: CommerceSessionEvent) -> State {
        switch event {
        case .created:
            return .commerceSessionCreated
        case .requiresAmount:
            return .commerceSessionRequiresAmount
        case .requiresTransaction:
            return .commerceSessionRequiresTransaction
        case .requiresApproval:
            return .commerceSessionRequiresApproval
        case .closed:
            return .commerceSessionClosed
        case .completed:
            return .commerceSessionCompleted
        }
    }

    func clear(canceled: Bool = false) {
        commerceSessionRepository.clearCurrent()
        closeCommerceSession()
        legacyMode = false
        paymentCompleted = false
        isUpdatingPaymentAsset = false
        transactionIsInProgress = false
        paymentEnabled = true
        state = .accountsLoaded
        accountRepository.backgroundRefresh()
    }

    private func notifyPaymentAuthorizationChange(_ commerceSession: CommerceSession) {
        guard let status = commerceSession.authorization?.status, status == .succeeded || status == .failed else {
            return
        }

        let fxStatus = FXPaymentAuthorization(
            status: status == .succeeded ? FXPaymentAuthorization.Status.succeeded : FXPaymentAuthorization.Status.failed,
            commerceSessionId: commerceSession.id,
            brandName: commerceSession.brand?.name ?? "",
            brandLogoUrl: commerceSession.brand?.logoUrl
        )

        onPaymentAuthorization?(fxStatus)
    }
}
