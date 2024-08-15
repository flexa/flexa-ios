//
//  CommerceSession.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/20/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public enum CommerceSessionStatus: String {
    case completed, unknown
    case requiresPaymentAsset = "requires_payment_asset"
    case requiresTransaction = "requires_transaction"
}

public protocol CommerceSession {
    var id: String { get }
    var asset: String { get }
    var amount: String { get }
    var brand: Brand? { get }
    var label: String? { get }
    var rate: Rate { get }
    var preferences: CommerceSessionPreference { get }
    var status: CommerceSessionStatus { get }
    var transactions: [FlexaCore.Transaction] { get }
    var authorization: CommerceSessionAuthorization? { get set }
}

public protocol CommerceSessionPreference {
    var app: String? { get }
    var paymentAsset: String { get }
}

public protocol CommerceSessionAuthorization {
    var instructions: String { get }
    var number: String { get }
    var details: String { get }
}

public extension CommerceSession {
    var requestedTransaction: FlexaCore.Transaction? {
        transactions.first { $0.status == .requested }
    }
}
