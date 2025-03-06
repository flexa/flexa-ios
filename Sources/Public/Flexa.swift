//
//  Flexa.swift
//  Flexa SDK
//
//  Created by Rodrigo Ordeix on 10/5/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

@_exported import FlexaCore
@_exported import FlexaLoad
@_exported import FlexaSpend
@_exported import FlexaScan
import SwiftUI
import Foundation

public extension Flexa {
    final class Builder {
        private var flexa = FlexaInternal()

        init(_ sections: [Section]) {
            flexa.sections = sections
        }

        ///  Sets the list of assets with their balances for each user's wallet.
        /// - parameter assetAccounts: A set of assets and their respective balances for each of the wallet accounts from which your user can sign transactions using your app
        /// - returns self instance in order to chain other methods
        @discardableResult
        public func assetAccounts(_ assetAccounts: [FXAssetAccount]) -> Self {
            flexa.spendBuilder?.assetAccounts(assetAccounts)
            return self
        }

        /// Selects the app account and assets to be used by default on future transactions
        /// - parameter assetAccountHash: The account hash
        /// - parameter assetId: The CAIP-19 ID for the asset.
        /// - returns self instance in order to chain other methods
        @discardableResult
        public func selectedAsset(_ assetAccountHash: String, _ caipAssetId: String) -> Self {
            flexa.spendBuilder?.selectedAsset(assetAccountHash, caipAssetId)
            return self
        }

        /// Specifies the callback to be called by Flexa when a transaction should be signed and sent by the parent application
        /// - parameter callback: Will be invoked by FlexaSpend when a transaction is ready to be signed and sent. The callback will receive a `succes` with a `Transaction` object with all the information the parent application will need or a `failure` with an `Error`
        /// - returns self instance in order to chain other methods
        @discardableResult
        public func onTransactionRequest(_ callback: @escaping Flexa.TransactionRequestCallback) -> Self {
            flexa.spendBuilder?.onTransactionRequest(callback)
            flexa.scanBuilder?.onTransactionRequest(callback)
            return self
        }

        @discardableResult
        public func onSendHandoff(_ callback: @escaping Flexa.SendHandoff) -> Self {
            flexa.scanBuilder?.onSendHandoff(callback)
            return self
        }

        @discardableResult
        public func onBrowseHandoff(_ callback: @escaping FlexaScan.BrowseHandoff) -> Self {
            flexa.scanBuilder?.onBrowseHandoff(callback)
            return self
        }

        /// Builds a new instance of Flexa based on the configuration specified by the other builder methods
        func build() -> Flexa {
            let flexa = self.flexa

            self.flexa = FlexaInternal()
            return flexa
        }

        public func open() {
            build().open()
        }
    }
}

public extension Flexa {
    /// Specifies which sections to be displayed
    /// - parameter sections: The sections to be displayed
    static func sections(_ sections: [Section]) -> Flexa.Builder {
        FlexaInternal.uiSections(sections)
    }

    /// Opens the main screen
    ///
    /// If the user is already signed in then it will open the screens specified by the ``Flexa/sections`` method. If the user is not signed in the it will open the sign in/sign up screens.
    func open() {
        (self as? FlexaInternal)?.openMain()
    }
}

extension Flexa: @retroactive UniversalLinkHandlerProtocol {
    /**
     Handles universal links received by the parent application. Currently allows you to use universal links to speed up the sign in/sign up process.

     - parameter url: The url to be processed
     - returns: true if the SDK recongizes and is able to handle the url, and false otherwise

     For SwiftUI based applications this methos should be called on the main App body:
     ```swift
     struct SPMApp: App {
        init() {
            Flexa.initialize(...)
        }

        var body: some Scene {
        WindowGroup {
            ExampleView()
               .onOpenURL { url in
                   Flexa.processUniversalLink(url: url)
               }
        }
     }
     ```

     For UIKit based applications this method should be called on the application's `AppDelegate`:
     ```swift
     func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return handle(url: userActivity.webpageURL)
     }

     func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return handle(url: url)
     }

     func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return handle(url: url)
     }

     private func handle(url: URL?) -> Bool {
        guard let url = url {
            return false
        }
        return Flexa.processUniversalLink(url: url)
     }
     ```
     */
    @discardableResult
    public static func processUniversalLink(url: URL) -> Bool {
        FlexaInternal.handleUniversalLink(url: url)
    }
}
