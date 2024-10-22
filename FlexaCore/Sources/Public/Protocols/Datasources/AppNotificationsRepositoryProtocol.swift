//
//  AppNotificationsRepositoryProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 3/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol AppNotificationsRepositoryProtocol {
    var notifications: [AppNotification] { get }

    func delete(_ id: String) async throws
}
