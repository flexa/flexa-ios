//
//  AppAccountModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

extension Models {
    struct AppAccount: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case assets
            case accountId = "account_id"
        }

        var accountId: String
        var assets: [Asset]
    }
}

extension Models.AppAccount {
    struct Asset: FlexaModelProtocol {
        let asset: String
        let balance: String
        let key: Key?
        let value: Value
        let label: String
    }
}

extension Models.AppAccount.Asset {
    struct Key: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case length, prefix, secret
            case expiresAt = "expires_at"
        }

        let expiresAt: Int
        let length: Int
        let prefix: String
        let secret: String
    }
}

extension Models.AppAccount.Asset {
    struct Value: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case asset, label
            case labelTitleCase = "label_titlecase"
        }

        let asset: String
        let label: String
        let labelTitleCase: String
    }
}

extension Models.AppAccount: AppAccount {
    var accountAssets: [any AppAccountAsset] {
        get {
            assets
        }
        set {
            assets = newValue.compactMap { $0 as? Models.AppAccount.Asset }
        }
    }
}

extension Models.AppAccount.Asset: AppAccountAsset {
    var assetId: String {
        asset
    }

    var assetKey: AppAccountAssetKey? {
        key
    }

    var assetValue: AppAccountAssetValue {
        value
    }
}

extension  Models.AppAccount.Asset.Key: AppAccountAssetKey {
    var serverTimeOffset: TimeInterval {
        Container.shared.appAccountsRepository().syncDateOffset ?? 0
    }
}

extension Models.AppAccount.Asset.Value: AppAccountAssetValue {
}

extension Double: FlexaModelProtocol {
}

extension String: FlexaModelProtocol {
}
