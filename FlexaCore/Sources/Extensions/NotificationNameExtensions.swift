//
//  NotificationNameExtensions.swift
//
//  Created by Rodrigo Ordeix on 5/29/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension Notification.Name {
    private static let notificationNamePrefix = "co.flexa.sdk"
    static let flexaAuthorizationError: Notification.Name =
        .init(rawValue: "\(notificationNamePrefix).authorizationError")
}
