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
public final class FlexaSpend {
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
        auth.collect { result in
            self.showPaymentOrAuth(result: result)
        }
    }

    /// Returns a view containing the main FlexaSpend screen
    ///
    /// The returned view could be embedded inside other views.
    public func createView() -> some View {
        ZStack(alignment: .center) {
            MainViewWrapper(spend: self) {
                SpendView(viewModel: self.viewModel)
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
    }

    public static func transactionSent(commerceSessionId: String, signature: String) {
        Container
            .shared
            .appStateManager()
            .signTransaction(
                commerceSessionId: commerceSessionId,
                signature: signature
            )
    }

    /// Opens FlexaSpend's main screen, if the user is already signed in, or the sign in/sign up screen otherwise
    /// - parameter result: indicates if the user is authenticated (`connected`) or not
    ///
    /// If `result` is `connected` then FlexaSpend opens the main screen
    /// if `result` is `notConnected` then FlexaSpend starts the auth flow
    private func showPaymentOrAuth(result: ConnectResult, allowSignIn: Bool = true) {
        DispatchQueue.main.async {
            switch result {
                case .connected:
                    UIViewController.showViewOnTop(self.createView())
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
        @Injected(\.appAccountsRepository) private var appAccountsRepository
        @Injected(\.assetsRepository) private var assetsRepository

        private var spend: FlexaSpend?
        private var appAccounts: [FXAppAccount] = []

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
        /// - parameter appAccountId: The app account identifier
        /// - parameter assetId: The CAIP-19 ID for the asset.
        /// - returns self instance in order to chain other methods
        @discardableResult
        public func selectedAsset(_ appAccountId: String, _ assetId: String) -> Self {
            assetConfig.selectedAppAccountId = appAccountId
            assetConfig.selectedAssetId = assetId
            return self
        }

        ///  Sets the list of assets with their balances for each user's wallet.
        /// - parameter appAccounts: A set of assets and their respective balances for each of the wallet accounts from which your user can sign transactions using your app
        /// - returns self instance in order to chain other methods
        @discardableResult
        public func appAccounts(_ appAccounts: [FXAppAccount]) -> Self {
            self.appAccounts = appAccounts
            flexaClient.appAccounts = appAccounts
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

            if !appAccounts.isEmpty {
                Flexa.updateAppAccounts(appAccounts)
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
}

// MARK: View Wrappers and Environment Objects
private extension FlexaSpend {
    struct MainViewWrapper<Content: View>: View {
        @Injected(\.flexaClient) var flexaClient
        @Environment(\.colorScheme) var colorScheme
        @Environment(\.dismiss) var dismiss
        @StateObject var modalState = SpendModalState()

        var spend: FlexaSpend
        var content: () -> Content

        var body: some View {
            content()
                .ignoresSafeArea()
                .environment(\.colorScheme, flexaClient.theme.interfaceStyle.colorSheme ?? colorScheme)
                .environmentObject(modalState)
                .environment(\.dismissAll, dismiss)
                .theme(flexaClient.theme)
                .cornerRadius(flexaClient.theme.views.primary.borderRadius, corners: [.topLeft, .topRight])
                .onAuthorizationError {
                    FlexaIdentity.disconnect()
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        spend.open()
                    }
                }
        }

        init(spend: FlexaSpend, @ViewBuilder content: @escaping () -> Content) {
            self.spend = spend
            self.content = content
        }
    }
}
