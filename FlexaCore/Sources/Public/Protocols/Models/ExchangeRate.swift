//
//  Fee.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 9/27/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol ExchangeRate {
    var asset: String { get }
    var expiresAt: Int { get }
    var label: String { get }
    var precision: Int { get }
    var price: String { get }
    var unitOfAccount: String { get }
    var decimalPrice: Decimal { get }
    var isExpired: Bool { get }
}
