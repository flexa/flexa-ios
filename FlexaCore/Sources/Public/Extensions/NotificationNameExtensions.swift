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
    static let appAccountsDidUpdate: Notification.Name =
        .nameWithPrefix("appAccountsDidUpdate")

    private static func nameWithPrefix(_ name: String) -> Notification.Name {
        .init(rawValue: "\(prefix).\(name)")
    }
}
