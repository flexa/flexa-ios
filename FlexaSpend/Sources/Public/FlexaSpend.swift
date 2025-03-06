//
//  FlexaSpend.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 10/5/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

@_exported import FlexaCore
import FlexaUICore
import SwiftUI
import Factory

/// The entry point of FlexaSpend
public final class FlexaSpend: UniversalLinkHandlerProtocol {
    @Injected(\.appStateManager) private var appStateManager
    private var auth: FlexaIdentity!
    private var viewModel = Container.shared.spendViewViewModel(nil)

    /// Block that will be called when a Transaction is ready to be sent.
    ///
    /// This block/callback will be used by FlexaSpend to notify the parent application it should review, sign and send a transaction
    public var onTransactionRequestCallback: Flexa.TransactionRequestCallback? {
        didSet {
            viewModel.signTransaction = onTransactionRequestCallback
        }
    }

    private init() {
        auth = Flexa
            .buildIdentity()
            .delayCallbacks(false)
            .onResult { result in
                self.showPaymentOrAuth(result: result, allowSignIn: false)
            }
            .build()
    }

    /// Opens FlexaSpend's main screen
    ///
    /// If the user is already signed in then it will open the payment screen.
    /// If the user is not signed in the it will open the sign in/sign up screens.
    public func open() {
        appStateManager.closeCommerceSessionOnDismissal = true
        guard Flexa.canSpend else {
            FlexaLogger.error(L10n.Errors.RestrictedRegion.message)
            FlexaIdentity.showRestrictedRegionView()
            return
        }
        auth.collect { result in
            self.showPaymentOrAuth(result: result)
        }
    }

    /// Returns a view containing the main FlexaSpend screen
    ///
    /// The returned view could be embedded inside other views.
    public func createView() -> some View {
        createView(addModalHandling: false)
    }

    public static func transactionSent(commerceSessionId: String, signature: String) {
        FlexaLogger.commerceSessionLogger.debug("Flexa.transactionSent(cs: \(commerceSessionId), hash: \(signature))")
        Container
            .shared
            .appStateManager()
            .signTransaction(
                commerceSessionId: commerceSessionId,
                signature: signature
            )
    }

    public static func transactionFailed(commerceSessionId: String) {
        FlexaLogger.commerceSessionLogger.debug("Flexa.transactionFailed(cs: \(commerceSessionId))")
        Container
            .shared
            .appStateManager()
            .closeCommerceSession(commerceSessionId: commerceSessionId)
    }

    /// Opens FlexaSpend's main screen, if the user is already signed in, or the sign in/sign up screen otherwise
    /// - parameter result: indicates if the user is authenticated (`connected`) or not
    ///
    /// If `result` is `connected` then FlexaSpend opens the main screen
    /// if `result` is `notConnected` then FlexaSpend starts the auth flow
    private func showPaymentOrAuth(result: ConnectResult, allowSignIn: Bool = true) {
        guard Flexa.canSpend else {
            FlexaLogger.error(L10n.Errors.RestrictedRegion.message)
            return
        }
        DispatchQueue.main.async {
            switch result {
                case .connected:
                UIViewController.showViewOnTop(
                    self.createView(addModalHandling: true)
                )
                case .notConnected:
                    self.auth.open()
            }
        }
    }
}

// MARK: FlexaSpend.Builder
public extension FlexaSpend {
    final class Builder {
        @Injected(\.assetConfig) private var assetConfig
        @Injected(\.flexaClient) private var flexaClient
        @Injected(\.assetsRepository) private var assetsRepository

        private var spend: FlexaSpend?
        private var assetAccounts: [FXAssetAccount] = []

        private var safeSpend: FlexaSpend {
            if let spend {
                return spend
            }
            let newInstance = FlexaSpend()
            spend = newInstance
            return newInstance
        }

        fileprivate init() {
        }

        /// Selects the app account and assets to be used by default on future transactions
        /// - parameter assetAccountHash: The account hash
        /// - parameter assetId: The CAIP-19 ID for the asset.
        /// - returns self instance in order to chain other methods
        @discardableResult
        public func selectedAsset(_ assetAccountHash: String, _ assetId: String) -> Self {
            assetConfig.selectedAssetAccountHash = assetAccountHash
            assetConfig.selectedAssetId = assetId
            return self
        }

        ///  Sets the list of assets with their balances for each user's wallet.
        /// - parameter assetAccounts: A set of assets and their respective balances for each of the wallet accounts from which your user can sign transactions using your app
        /// - returns self instance in order to chain other methods
        @discardableResult
        public func assetAccounts(_ assetAccounts: [FXAssetAccount]) -> Self {
            self.assetAccounts = assetAccounts
            flexaClient.assetAccounts = assetAccounts
            return self
        }

        /// Specifies the callback to be called by FlexaSpend when a transaction should be signed and sent by the parent application
        /// - parameter callback: Will be invoked by FlexaSpend when a transaction is ready to be signed and sent. The callback will receive a `succes` with a `Transaction` object with all the information the parent application will need or a `failure` with an `Error`
        /// - returns self instance in order to chain other methods
        @discardableResult
        public func onTransactionRequest(_ callback: @escaping Flexa.TransactionRequestCallback) -> Self {
            self.safeSpend.onTransactionRequestCallback = callback
            return self
        }

        /// Builds a new instance of FlexaSpend based on the configuration specified by the other builder methods (`assetConfig`, `themeConfig`, callbacks)
        public func build() -> FlexaSpend {
            assetsRepository.backgroundRefresh()

            if !assetAccounts.isEmpty {
                Flexa.updateAssetAccounts(assetAccounts)
            }

            let payment = self.safeSpend
            self.spend = nil
            return payment
        }

        public func open() {
            build().open()
        }

        public func createView() -> some View {
            build().createView()
        }
    }
}

// MARK: FlexaSpend.Builder generator
public extension Flexa {
    /// Creates a builder for FlexaSpend
    /// - returns a new instance FlexaSpend.Builder that should be used to configure and build a new `FlexaSpend` object
    static func buildSpend() -> FlexaSpend.Builder {
        return FlexaSpend.Builder()
    }

    static func transactionSent(commerceSessionId: String, signature: String) {
        FlexaSpend.transactionSent(commerceSessionId: commerceSessionId, signature: signature)
    }

    static func transactionFailed(commerceSessionId: String) {
        FlexaSpend.transactionFailed(commerceSessionId: commerceSessionId)
    }
}

// MARK: View Wrappers and Environment Objects
private extension FlexaSpend {
    private func createView(addModalHandling: Bool) -> some View {
        guard Flexa.canSpend else {
            FlexaLogger.error(L10n.Errors.RestrictedRegion.message)
            return AnyView(EmptyView())
        }
        return AnyView(
            ZStack(alignment: .center) {
                if addModalHandling {
                    MainViewWrapperWithModalHandling(spend: self) {
                        SpendView(viewModel: self.viewModel)
                    }
                } else {
                    MainViewWrapper(spend: self) {
                        SpendView(viewModel: self.viewModel)
                    }
                }
            }
                .ignoresSafeArea()
                .navigationBarHidden(true)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .center
                )
        )
    }

    struct MainViewWrapperWithModalHandling<Content: View>: View {
        @StateObject var modalState = SpendModalState()
        @StateObject var linkData: UniversalLinkData = Container.shared.universalLinkData()

        var spend: FlexaSpend
        var content: () -> Content

        init(spend: FlexaSpend, @ViewBuilder content: @escaping () -> Content) {
            self.spend = spend
            self.content = content
        }

        var body: some View {
            MainViewWrapper(spend: spend, content: content)
                .environmentObject(modalState)
                .flexaHandleUniversalLink()
                .environmentObject(linkData)
        }

    }

    struct MainViewWrapper<Content: View>: View {
        @Injected(\.flexaClient) var flexaClient
        @Environment(\.colorScheme) var colorScheme
        @Environment(\.dismiss) var dismiss

        var spend: FlexaSpend
        var content: () -> Content

        var body: some View {
            content()
                .ignoresSafeArea()
                .environment(\.colorScheme, flexaClient.theme.interfaceStyle.colorSheme ?? colorScheme)
                .environment(\.dismissAll, dismiss)
                .theme(flexaClient.theme)
                .cornerRadius(flexaClient.theme.views.primary.borderRadius, corners: [.topLeft, .topRight])
                .onAuthorizationError {
                    FlexaIdentity.disconnect()
                    dismiss()
                }
        }

        init(spend: FlexaSpend, @ViewBuilder content: @escaping () -> Content) {
            self.spend = spend
            self.content = content
        }
    }
}
