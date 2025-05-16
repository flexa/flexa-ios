//
//  NotificationNameExtensions.swift
//
//  Created by Rodrigo Ordeix on 5/29/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public extension Notification.Name {
    private static let prefix = "co.flexa.sdk"
    static let flexaAuthorizationError: Notification.Name =
        .nameWithPrefix("authorizationError")
    static let oneTimeKeysDidUpdate: Notification.Name =
        .nameWithPrefix("oneTimeKeysDidUpdate")
    static let transactionSent: Notification.Name =
        .nameWithPrefix("transactionSent")
    static let assetAccountsDidChange: Notification.Name =
        .nameWithPrefix("assetAccountsDidChange")
    static let flexaComponentScanSelected: Notification.Name =
        .nameWithPrefix("flexaComponentScanSelected")
    static let flexaComponentLoadSelected: Notification.Name =
        .nameWithPrefix("flexaComponentLoadSelected")
    static let flexaComponentSpendSelected: Notification.Name =
        .nameWithPrefix("flexaComponentSpendSelected")

    private static func nameWithPrefix(_ name: String) -> Notification.Name {
        .init(rawValue: "\(prefix).\(name)")
    }
}
