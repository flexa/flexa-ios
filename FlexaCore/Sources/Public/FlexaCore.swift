//
//  FlexaCore.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/5/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Factory
import UIKit
import SwiftUI

/// The entry point of Flexa SDK.
///
/// Initialize and configure `Flexa` using `Flexa.initialize(config:)`
open class Flexa {

    public typealias TransactionRequestCallback = (Result<FXTransaction, Error>) -> Void
    public typealias PaymentAuthorizationCallback = (FXPaymentAuthorization) -> Void
    public typealias SendHandoff = (FXTransaction) -> Void

    @Injected(\.flexaClient) private static var flexaClient
    @Injected(\.assetConfig) private static var assetConfig
    @Injected(\.assetsRepository) private static var assetsRepository
    @Injected(\.appStateManager) private static var appStateManager
    @Injected(\.authStore) private static var authStore
    @Injected(\.oneTimeKeysRepository) private static var oneTimeKeysRepository
    @Injected(\.eventNotifier) private static var eventNotifier
    private static var isInitialized = false

    @Synchronized public static internal(set) var canSpend = true {
        didSet {
            if !canSpend {
                eventNotifier.post(name: .flexaAuthorizationError)
            }
        }
    }

    /// Initializes Flexa SDK with the specified settings.
    ///
    /// This is typically  done on:
    /// - UIKit: the app's `application:didFinishLaunchingWithOptions`
    /// - SwiftUI: `main` App `init` method
    ///
    /// - parameter settings: The FXClient used to configure Flexa SDK.
    public static func initialize(_ client: FXClient) {
        flexaClient.publishableKey = client.publishableKey
        flexaClient.assetAccounts = client.assetAccounts
        flexaClient.theme.loadFrom(client.theme)

        if !isInitialized {
            assetsRepository.backgroundRefresh()
            appStateManager.backgroundRefresh()
            isInitialized.toggle()
        }
    }

    ///  Updates the list of assets with their balances for each user's wallet.
    /// - parameter assetAccounts: A set of assets and their respective balances for each of the wallet accounts from which your user can sign transactions using your app
    public static func updateAssetAccounts(_ assetAccounts: [FXAssetAccount]) {
        flexaClient.assetAccounts = assetAccounts
        eventNotifier.post(name: .assetAccountsDidChange)
        if authStore.isAuthenticated {
            oneTimeKeysRepository.backgroundRefresh()
        } else {
            appStateManager.backgroundRefresh()
        }
    }

    /// Selects the account and asset to be used by default on future transactions
    /// - parameter assetAccountHash: The asset account hash
    /// - parameter assetId: The CAIP-19 ID for the asset.
    public static func selectedAsset(_ assetAccountHash: String, _ assetId: String) {
        assetConfig.selectedAssetAccountHash = assetAccountHash
        assetConfig.selectedAssetId = assetId
        flexaClient.sanitizeSelectedAsset()
    }

    /// Updates the theme Flexa uses to configure the user interface
    ///
    /// - parameter theme: A theme description used for customizing the Flexa user interface to integrate harmoniously with the rest of your app.
    public static func updateTheme(_ theme: FXTheme) {
        Self.flexaClient.theme = theme
    }

    @MainActor
    public static func showPaymentClip(commerceSession: CommerceSession, signTransaction: ((Result<FXTransaction, Error>) -> Void)?) {
        UIViewController.showViewOnTop(
            paymentClip(for: commerceSession, signTransaction: signTransaction),
            modalPresentationStyle: .overCurrentContext,
            modalTransitionStyle: .crossDissolve
        )
    }

    /// Dismisses the SDK.
    ///
    ///  - parameter closeCommerceSessions: Indicates to the SDK if the ongoing Commerce Sessions should be closed alongside the screens. If it's `false` and there was an ongoing Commerce Session, the next time the user opens the SDK it will try to resume the Commerce Session.
    ///  - parameter callback: A callback to be invoked once the SDK is dismissed.
    public static func close(_ closeCommerceSessions: Bool = true, callback: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            appStateManager.closeCommerceSessionOnDismissal = closeCommerceSessions
            UIApplication
                .shared
                .connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .last?.rootViewController?.dismiss(animated: true) {
                    callback?()
                }
        }
    }

    /// Invoked when a transaction finishes succesfully
    /// - parameter commerceSessionId: The current commerce session id
    /// - parameter signature: The transaction signature
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

    /// Invoked when a transaction fails
    /// - parameter commerceSessionId: The current commerce session id
    public static func transactionFailed(commerceSessionId: String) {
        FlexaLogger.commerceSessionLogger.debug("Flexa.transactionFailed(cs: \(commerceSessionId))")
        Container
            .shared
            .appStateManager()
            .closeCommerceSession(commerceSessionId: commerceSessionId)
    }

    public init() {
        guard String(describing: self) != "FlexaCore.Flexa" else {
            fatalError("You cannot instantiate Flexa directly. Please use a builder.")
        }
    }
}

private extension Flexa {
    struct StandalonePaymentClip<Content: View>: View {
        @Environment(\.theme) private var theme
        @Environment(\.colorScheme) private var colorScheme

        @StateObject var linkData = Container.shared.universalLinkData()
        @StateObject var flexaState = Container.shared.flexaState()
        var content: () -> Content

        var body: some View {
            content()
                .environmentObject(flexaState)
                .flexaHandleUniversalLink()
                .environmentObject(linkData)
                .environment(\.colorScheme, theme.interfaceStyle.colorSheme ?? colorScheme)
        }

        init(@ViewBuilder content: @escaping () -> Content) {
            self.content = content
        }
    }

    @MainActor
    static func paymentClip(for commerceSession: CommerceSession, signTransaction: ((Result<FXTransaction, Error>) -> Void)?) -> some View {
        let viewModel = CommerceSessionView.ViewModel(
            signTransaction: signTransaction,
            isStandalone: true
        )
        return StandalonePaymentClip {
            CommerceSessionView(viewModel: viewModel)
                .onAppear {
                    viewModel.startWatching()
                    viewModel.commerceSessionHandler.resumeCommerceSession(commerceSession, isLegacy: false, wasTransactionSent: false)
                }
                .onDisappear(perform: viewModel.stopWatching)
        }
    }
}
