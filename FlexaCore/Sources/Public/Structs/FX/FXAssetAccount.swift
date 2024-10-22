//
//  FXAssetAccount.swift
//  Flexa
//
//  Created by Rodrigo Ordeix on 12/12/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import UIKit

public struct FXAssetAccount {
    /// A unique identifier (e.g., SHA-256 hash or UUIDv4) that you generate in order to identify this asset account to Flexa SDK. When Flexa calls back to your app to sign a transaction, this assetAccountHash will be provided in order to identify the wallet account from which to spend.
    public let assetAccountHash: String
    /// The human-friendly name of the account, however it is represented throughout the rest of your app.
    public let displayName: String
    /// The icon that is used to uniquely identify this account throughout the app (optional). Must be masked according to how you want the icon represented within the Flexa user interface.
    public let icon: UIImage?
    /// An array of all assets that are available to the user to spend from this account. In order to ensure that your users can spend assets as they are enabled by Flexa, you should not filter this list by which assets are supported by Flexa at the time you publish your app.
    public let availableAssets: [FXAvailableAsset]
    /// local or managed
    public let custodyModel: CustodyModel

    public init(assetAccountHash: String,
                displayName: String,
                custodyModel: CustodyModel,
                availableAssets: [FXAvailableAsset],
                icon: UIImage? = nil) {
        self.assetAccountHash = assetAccountHash
        self.displayName = displayName
        self.availableAssets = availableAssets
        self.icon = icon
        self.custodyModel = custodyModel
    }
}

public extension Array where Element == FXAssetAccount {
    func findBy(assetAccountHash hash: String) -> FXAssetAccount? {
        first { $0.assetAccountHash.caseInsensitiveCompare(hash) == .orderedSame }
    }
}

public extension FXAssetAccount {
    enum CustodyModel: String {
        case local, managed
    }
}
