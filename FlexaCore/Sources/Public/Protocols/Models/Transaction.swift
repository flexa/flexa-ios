//
//  Transaction.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/20/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol Transaction {
    var id: String? { get }
    var asset: String? { get }
    var amount: String? { get }
    var label: String? { get }
    var signature: String? { get }
    var size: String? { get }
    var status: TransactionStatus? { get }
    var destination: Destination? { get }
    var fee: Fee? { get }
}
