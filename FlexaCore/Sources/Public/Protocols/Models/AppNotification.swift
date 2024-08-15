//
//  Account.swift
//  AppNotification
//
//  Created by Rodrigo Ordeix on 8/0/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol AppNotification {
    var id: String { get }
    var action: AppNotificationAction? { get }
    var title: String { get }
    var body: String { get }
    var iconUrl: URL? { get }
}

public protocol AppNotificationAction {
    var label: String { get }
    var url: URL? { get }
}
