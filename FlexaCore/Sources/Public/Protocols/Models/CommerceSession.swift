//
//  CommerceSession.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/20/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public enum CommerceSessionStatus: String {
    case completed, unknown, closed
    case requiresPaymentAsset = "requires_payment_asset"
    case requiresAmount = "requires_amount"
    case requiresTransaction = "requires_transaction"
    case requiresApproval = "requires_approval"
}

public enum CommerceSessionAuthorizationStatus: String {
    case failed, pending, succeeded
}

public protocol CommerceSession {
    var id: String { get }
    var asset: String { get }
    var amount: String { get }
    var brand: Brand? { get }
    var label: String? { get }
    var rate: Rate? { get }
    var preferences: CommerceSessionPreference { get }
    var status: CommerceSessionStatus { get }
    var transactions: [FlexaCore.Transaction] { get }
    var authorization: CommerceSessionAuthorization? { get set }
    var credits: [FlexaCore.CommerceSessionCredit] { get }
}

public protocol CommerceSessionPreference {
    var app: String? { get }
    var paymentAsset: String { get }
}

public protocol CommerceSessionAuthorization {
    var instructions: String? { get }
    var number: String { get }
    var details: String? { get }
    var status: CommerceSessionAuthorizationStatus { get }
}

public protocol CommerceSessionCredit {
    var id: String { get }
    var amount: String { get }
    var asset: String { get }
    var label: String { get }
    var status: String { get }
}

public extension CommerceSession {
    var requestedTransaction: FlexaCore.Transaction? {
        transactions.first { $0.status == .requested }
    }

    var isClosed: Bool {
        status == .closed
    }

    var isCompleted: Bool {
        status == .completed
    }

    var requiresApproval: Bool {
        status == .requiresApproval
    }

    var requiresTransaction: Bool {
        status == .requiresTransaction
    }
}
