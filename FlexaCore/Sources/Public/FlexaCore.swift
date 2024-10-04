//
//  FlexaCore.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/5/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Factory

/// The entry point of Flexa SDK.
///
/// Initialize and configure `Flexa` using `Flexa.initialize(config:)`
open class Flexa {

    public typealias TransactionRequestCallback = (Result<FXTransaction, Error>) -> Void
    public typealias SendHandoff = (FXTransaction) -> Void

    @Injected(\.flexaClient) private static var flexaClient
    @Injected(\.assetConfig) private static var assetConfig
    @Injected(\.appStateManager) private static var appStateManager
    @Injected(\.oneTimeKeysRepository) private static var oneTimeKeysRepository
    private static var isInitialized = false

    /// Initializes Flexa SDK with the specified settings.
    ///
    /// This is typically  done on:
    /// - UIKit: the app's `application:didFinishLaunchingWithOptions`
    /// - SwiftUI: `main` App `init` method
    ///
    /// - parameter settings: The FXClient used to configure Flexa SDK.
    public static func initialize(_ client: FXClient) {
        flexaClient.publishableKey = client.publishableKey
        flexaClient.appAccounts = client.appAccounts
        flexaClient.theme = client.theme

        if !isInitialized {
            appStateManager.backgroundRefresh()
            isInitialized.toggle()
        }
    }

    ///  Updates the list of assets with their balances for each user's wallet.
    /// - parameter appAccounts: A set of assets and their respective balances for each of the wallet accounts from which your user can sign transactions using your app
    public static func updateAppAccounts(_ appAccounts: [FXAppAccount]) {
        flexaClient.appAccounts = appAccounts
        oneTimeKeysRepository.backgroundRefresh()
    }

    /// Selects the app account and asset to be used by default on future transactions
    /// - parameter appAccountId: The app account identifier
    /// - parameter assetId: The CAIP-19 ID for the asset.
    public static func selectedAsset(_ appAccountId: String, _ assetId: String) {
        assetConfig.selectedAppAccountId = appAccountId
        assetConfig.selectedAssetId = assetId
        flexaClient.sanitizeSelectedAsset()
    }

    /// Updates the theme Flexa uses to configure the user interface
    ///
    /// - parameter theme: A theme description used for customizing the Flexa user interface to integrate harmoniously with the rest of your app.
    public static func updateTheme(_ theme: FXTheme) {
        Self.flexaClient.theme = theme
    }

    public init() {
        guard String(describing: self) != "FlexaCore.Flexa" else {
            fatalError("You cannot instantiate Flexa directly. Please use a builder.")
        }
    }
}
