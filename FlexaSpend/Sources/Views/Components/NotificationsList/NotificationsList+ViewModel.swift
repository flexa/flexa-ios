//
//  NotificationsList.swift
//  FlexasSpend
//
//  Created by Rodrigo Ordeix on 8/8/24.
//  Copyright © 2022 Flexa. All rights reserved.
//

import SwiftUI
import Factory

extension NotificationsList {
    class ViewModel: ObservableObject {
        @Injected(\.appNotificationsRepository) var appNotificationsRepository
        @Published var notifications: [AppNotification] = []

        init() {
            notifications = appNotificationsRepository.notifications
        }

        func deleteNotification(_ id: String) {
            notifications.removeAll { $0.id == id }
            Task {
                do {
                    try await appNotificationsRepository.delete(id)
                } catch let error {
                    FlexaLogger.error(error)
                }
            }
        }
    }
}
