//
//  AppStateManager.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/22/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory
import UIKit

class AppStateManager: AppStateManagerProtocol {
    @Injected(\.appAccountsRepository) var appAccountsRepository
    @Injected(\.transactionsRespository) var transactionsRepository
    @Injected(\.accountRepository) var accountsRepository
    @Injected(\.brandsRepository) var brandsRepository
    @Injected(\.assetsRepository) var assetsRepository
    @Injected(\.authStore) var authStore
    @Injected(\.flexaNotificationCenter) var flexaNotificationCenter

    private let notificationCenter = NotificationCenter.default
    private let queue = DispatchQueue(label: "refreshTokenQueue")
    private let accessTokenRefreshthreshold = 5 * 60
    private let timerCadence = 60
    private var timer: DispatchSourceTimer?
    // Use a cache with expiring entries here
    private var unsignedTransactions: [String: String] = [:]

    init() {
        notificationCenter.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func appDidBecomeActive() {
        refresh()
    }

    @objc func appDidEnterBackground() {
        stopTimer()
    }

    func refresh() {
        startTimer()
        guard authStore.isSignedIn else {
            return
        }

        accountsRepository.backgroundRefresh()
        assetsRepository.backgroundRefresh()
        brandsRepository.backgroundRefresh()
        appAccountsRepository.backgroundRefresh()
    }

    func addTransaction(commerceSessionId: String, transactionId: String) {
        unsignedTransactions[commerceSessionId] = transactionId
    }

    func signTransaction(commerceSessionId: String, signature: String) {
        guard let transactionId = unsignedTransactions[commerceSessionId] else {
            return
        }
        unsignedTransactions.removeValue(forKey: commerceSessionId)

        Task {
            do {
                try await transactionsRepository.addSignature(transactionId: transactionId, signature: signature)
            } catch let error {
                FlexaLogger.error(error)
            }
        }

    }
}

private extension AppStateManager {
    var shouldRefreshAccessToken: Bool {
        guard let token = authStore.token, token.isActive || token.isExpired else {
            return false
        }

        guard !token.isExpired else {
            return true
        }

        guard let secondsLeft = token.expiringIn, secondsLeft < accessTokenRefreshthreshold else {
            return false
        }

        return true
    }

    func startTimer() {
        stopTimer()

        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: .seconds(timerCadence))
        timer?.setEventHandler { [weak self] in
            self?.refreshAccessToken()
        }
        timer?.resume()
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    func refreshAccessToken() {
        guard shouldRefreshAccessToken else {
            return
        }

        Task {
            do {
                _ = try await authStore.refreshToken()
            } catch let error {
                if error.isUnauthorized {
                    flexaNotificationCenter.post(name: .flexaAuthorizationError, object: nil)
                }
                FlexaLogger.error(error)
            }
        }
    }
}
