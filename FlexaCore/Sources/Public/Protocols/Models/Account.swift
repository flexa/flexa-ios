//
//  Account.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/31/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol EmptyAccount {
}

public enum AccountStatus: String {
    case pendingDeletion = "pending_deletion"
    case unknown
}

public protocol Account {
    var id: String { get }
    var familyName: String { get }
    var givenName: String { get }
    var fullName: String { get }
    var emailAddress: String { get }
    var status: AccountStatus { get }
    var unitOfAccount: String? { get }
    var balance: AccountBalance? { get }
    var limits: [AccountLimit] { get }
    var notifications: [AppNotification] { get }
    var pinnedBrands: [String] { get }
    var joinedIn: Date { get }
}

public extension Account {
    var hasBalance: Bool {
        guard let balance else {
            return false
        }
        return !balance.isEmpty
    }
}

public protocol AccountBalance {
    var amount: String? { get }
    var asset: String? { get }
    var label: String? { get }
}

public extension AccountBalance {
    var isEmpty: Bool {
        [amount, asset].contains { $0 == nil }
    }
}

public protocol AccountLimit {
    var name: String { get }
    var label: String { get }
    var description: String { get }
    var amount: Decimal { get }
    var remaining: Decimal { get }
    var resetsAt: Date? { get }
}
