//
//  FlexaCore.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/5/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Factory
import UIKit

/// The entry point of Flexa SDK.
///
/// Initialize and configure `Flexa` using `Flexa.initialize(config:)`
open class Flexa {

    public typealias TransactionRequestCallback = (Result<FXTransaction, Error>) -> Void
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
        flexaClient.theme = client.theme

        if !isInitialized {
            appStateManager.purgeIfNeeded()
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

    public init() {
        guard String(describing: self) != "FlexaCore.Flexa" else {
            fatalError("You cannot instantiate Flexa directly. Please use a builder.")
        }
    }
}
