//
//  AppNotificatoinsRepository.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 8/9/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

class AppNotificationsRepository: AppNotificationsRepositoryProtocol {
    @Injected(\.networkClient) var networkClient
    @Injected(\.accountRepository) var accountRepository
    @Injected(\.keychainHelper) var keychain

    var notifications: [AppNotification] {
        accountRepository
            .account?
            .notifications
            .filter { !deletedIds.contains($0.id) } ?? []
    }

    var deletedIds: [String] = []

    init() {
        deletedIds = keychain.value(forKey: .deletedAppNotifications) ?? []
    }

    func delete(_ id: String) async throws {
        deletedIds.append(id)
        keychain.setValue(deletedIds, forKey: .deletedAppNotifications)

        try await networkClient.sendRequest(
            resource: AppNotificationsResource.delete(id)
        )
    }
}
