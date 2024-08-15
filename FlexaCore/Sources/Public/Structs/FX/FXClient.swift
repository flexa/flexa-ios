//
//  FXClient.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/18/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation

/**
 * Represents Flexa SDK configuration.
 *
 *  Encapsulates the main configuration Flexa needs to interact with the backend
 */
public final class FXClient {
    /// The publishable key provided by Flexa that enables your app to authenticate against the Flexa API.
    public var publishableKey: String

    /// A set of assets and their respective balances for each of the wallet accounts from which your user can sign transactions using your app. A single app account will usually correspond directly to a single derivation path for any given private key that your user has configured with your app.
    public var appAccounts: [FXAppAccount]

    /// A theme description used for customizing the Flexa user interface to integrate harmoniously with the rest of your app.
    public var theme: FXTheme

    /// Returns true if all the required configuration fields are present
    public var isValid: Bool {
        !publishableKey.isEmpty
    }

    /// An empty and invalid instance of `SpendConfig` that could be used as a default value
    public static let empty: FXClient = .init(publishableKey: "", appAccounts: [], theme: .default)

    /// Initializes the instance with the config values
    /// - parameters
    ///     - publishableKey: The publishable key provided by Flexa that enables your app to authenticate against the Flexa API.
    ///     - theme: A theme description used for customizing the Flexa user interface to integrate harmoniously with the rest of your app.
    public init(
        publishableKey: String,
        appAccounts: [FXAppAccount],
        theme: FXTheme = .default) {
            self.publishableKey = publishableKey
            self.appAccounts = appAccounts
            self.theme = theme
        }

    /// Initializes the instance with the config values
    /// - parameters
    ///     - publishableKey: The publishable key provided by Flexa that enables your app to authenticate against the Flexa API.
    ///     - themingDataString: A json string containing a theme description used for customizing the Flexa user interface to integrate harmoniously with the rest of your
    public convenience init(
        publishableKey: String,
        appAccounts: [FXAppAccount],
        themingDataString: String? = nil) {
            self.init(
                publishableKey: publishableKey,
                appAccounts: appAccounts,
                theme: FXTheme.fromJsonString(themingDataString ?? ""))
        }
}
