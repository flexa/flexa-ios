//
//  ConvertedAsset.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/12/24.
//

import Foundation

public protocol ConvertedAsset: Value {
    var unitOfAccount: String { get }
    var fee: Fee { get }
    var value: ConvertedAssetValue { get }
}

public protocol ConvertedAssetValue: Value {
    var rate: Rate { get }
}
