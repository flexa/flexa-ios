//
//  FXAppAccount.swift
//  Flexa
//
//  Created by Rodrigo Ordeix on 12/12/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import UIKit

public struct FXAppAccount {
    /// A unique identifier (e.g., SHA-256 hash or UUIDv4) that you generate in order to identify this app account to Flexa SDK. When Flexa calls back to your app to sign a transaction, this accountId will be provided in order to identify the wallet account from which to spend. By reusing this ID across sessions, Flexa will avoid garbage-collecting account numbers and can ensure that offline payments will work for longer periods of time.
    public let accountId: String
    /// The human-friendly name of the account, however it is represented throughout the rest of your app.
    public let displayName: String
    /// The icon that is used to uniquely identify this account throughout the app (optional). Must be masked according to how you want the icon represented within the Flexa user interface.
    public let icon: UIImage?
    /// An array of all assets that are available to the user to spend from this account. In order to ensure that your users can spend assets as they are enabled by Flexa, you should not filter this list by which assets are supported by Flexa at the time you publish your app.
    public let availableAssets: [FXAvailableAsset]
    /// local or managed
    public let custodyModel: CustodyModel

    public init(accountId: String,
                displayName: String,
                custodyModel: CustodyModel,
                availableAssets: [FXAvailableAsset],
                icon: UIImage? = nil) {
        self.accountId = accountId
        self.displayName = displayName
        self.availableAssets = availableAssets
        self.icon = icon
        self.custodyModel = custodyModel
    }
}

public extension Array where Element == FXAppAccount {
    func findBy(accountId: String) -> FXAppAccount? {
        first { $0.accountId.caseInsensitiveCompare(accountId) == .orderedSame }
    }
}

public extension FXAppAccount {
    enum CustodyModel: String {
        case local, managed
    }
}
