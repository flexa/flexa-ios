//
//  Transaction.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 2/21/23.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation

/// Represents a Transaction to be made
///
/// Flexa will pass back a Transaction object to the parent application in order to be reviewed, signed and sent
public struct FXTransaction: FlexaModelProtocol {
    /// The Commerce Sessions identifier associated to the transaction
    public let commerceSessionId: String
    /// Amount of the transaction
    public let amount: String
    /// The account hash the funds will be taken from
    public let assetAccountHash: String
    /// The asset that must be used
    public let assetId: String
    /// Destination address of the transaction
    public let destinationAddress: String
    /// Calculated fee amount
    public let feeAmount: String
    /// The fee assetId, ETH for Ethereum, BTC for bitcoin network etc
    public let feeAssetId: String
    /// Fee price. Gas price on Ethereum, or the sats/vByte fee on Bitcoin
    public let feePrice: String
    /// Priority fee amount (Ethereum only)
    public let feePriorityPrice: String?
    /// Gas limit (Ethereum only)
    public let size: String?
    // Brand'fields
    public let brandLogo, brandName, brandColor: String?

    public init(commerceSessionId: String,
                amount: String,
                assetAccountHash: String,
                assetId: String,
                destinationAddress: String,
                feeAmount: String,
                feeAssetId: String,
                feePrice: String,
                feePriorityPrice: String?,
                size: String?,
                brandLogo: String?,
                brandName: String?,
                brandColor: String?
    ) {
        self.commerceSessionId = commerceSessionId
        self.amount = amount
        self.assetAccountHash = assetAccountHash
        self.assetId = assetId
        self.destinationAddress = destinationAddress
        self.feeAmount = feeAmount
        self.feeAssetId = feeAssetId
        self.feePrice = feePrice
        self.feePriorityPrice = feePriorityPrice
        self.size = size
        self.brandLogo = brandLogo
        self.brandName = brandName
        self.brandColor = brandColor
    }
}
