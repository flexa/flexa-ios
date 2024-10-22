//
//  Fee.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/20/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol Fee {
    var amount: String { get }
    var asset: String { get }
    var price: Price? { get }
    var zone: String? { get }
    var transactionAsset: String? { get }
}
