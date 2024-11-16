//
//  AccountModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/16/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension Models {
    struct EmptyAccount: FlexaModelProtocol {
    }

    struct Account: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case id, name
            case statusString = "status"
            case accountBalance = "balance"
            case unitOfAccount = "unit_of_account"
            case accountLimits = "limits"
            case accountNotifications = "notifications"
            case accountPinnedBrands = "pinned_brands"
            case created = "created"
        }

        var id: String
        var name: String
        var emailAddress: String = ""
        var statusString: String?
        var unitOfAccount: String?
        var accountBalance: Balance?
        var accountLimits: [Limit]
        var accountNotifications: [AppNotification]
        var accountPinnedBrands: [String]?
        var created: Int
    }
}

extension Models.Account {
    struct Balance: FlexaModelProtocol {
        var amount, asset, label: String?
    }
}

extension Models.EmptyAccount: EmptyAccount {
}

extension Models.Account {
    struct Limit: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case name, label, description
            case amountString = "amount"
            case remainingString = "remaining"
            case resetsAtSeconds = "resets_at"
        }
        var name, label, description, amountString, remainingString: String
        var resetsAtSeconds: Int
    }
}

extension Models.Account: Account {
    var fullName: String {
        name
    }

    var givenName: String {
        name.split(separator: " ")
            .compactMap { $0 }
            .map { String($0) }
            .first ?? ""
    }

    var familyName: String {
        let split = name.split(separator: " ", maxSplits: 1)
        guard split.count == 2 else {
            return ""
        }
        return String(split[1])
    }

    var status: AccountStatus {
        get {
            AccountStatus(rawValue: statusString ?? "") ?? .unknown
        }
        set {
            statusString = newValue.rawValue
        }
    }

    var joinedIn: Date {
        Date(timeIntervalSince1970: TimeInterval(created))
    }

    var balance: (any AccountBalance)? {
        accountBalance
    }

    var limits: [any AccountLimit] {
        accountLimits
    }

    var notifications: [any AppNotification] {
        accountNotifications
    }

    var pinnedBrands: [String] {
        accountPinnedBrands ?? []
    }
}

extension Models.Account.Balance: AccountBalance {
}

extension Models.Account.Limit: AccountLimit {
    var resetsAt: Date? {
        Date(timeIntervalSince1970: TimeInterval(resetsAtSeconds))
    }

    var amount: Decimal {
        amountString.decimalValue ?? 0
    }

    var remaining: Decimal {
        remainingString.decimalValue ?? 0
    }
}
