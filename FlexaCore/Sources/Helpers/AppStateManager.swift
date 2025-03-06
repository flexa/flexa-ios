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
    @Injected(\.oneTimeKeysRepository) var oneTimeKeysRepository
    @Injected(\.transactionsRespository) var transactionsRepository
    @Injected(\.commerceSessionRepository) var commerceSessionRepository
    @Injected(\.accountRepository) var accountsRepository
    @Injected(\.brandsRepository) var brandsRepository
    @Injected(\.assetsRepository) var assetsRepository
    @Injected(\.exchangeRatesRepository) var exchangeRateRepository
    @Injected(\.authStore) var authStore
    @Injected(\.eventNotifier) var eventNotifier
    @Injected(\.flexaClient) var flexaClient
    @Injected(\.userDefaults) var userDefaults

    @Synchronized var closeCommerceSessionOnDismissal: Bool = true
    private let notificationCenter = NotificationCenter.default
    private let queue = DispatchQueue(label: "refreshTokenQueue")
    private let accessTokenRefreshthreshold = 5 * 60
    private let timerCadence = 60
    private var timer: DispatchSourceTimer?
    // Use a cache with expiring entries here
    private var unsignedTransactions: [String: String] = [:]
    @Synchronized private var backgroundRefreshAsyncTask: Task<Void, Never>?
    @Synchronized private var isRefreshing = false

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
        backgroundRefresh()
    }

    @objc func appDidEnterBackground() {
        stopTimer()
    }

    func backgroundRefresh() {
        Task {
            if !isRefreshing {
                isRefreshing = true
                await backgroundRefreshTask()
                backgroundRefreshAsyncTask = nil
                isRefreshing = false
            }
        }
        startTimer()
    }

    func refresh() async {
        guard authStore.isAuthenticated else {
            return
        }
        do {
            try await accountsRepository.refresh()
            try await assetsRepository.refresh()
            try await brandsRepository.refresh()
            try await brandsRepository.refreshLegacyFlexcodeBrands()

            if !flexaClient.assetAccounts.isEmpty {
                try await oneTimeKeysRepository.refresh()
                try await exchangeRateRepository.refresh()
            }
        } catch let error {
            FlexaLogger.error(error)
        }
    }

    func addTransaction(commerceSessionId: String, transactionId: String) {
        unsignedTransactions[commerceSessionId] = transactionId
    }

    func signTransaction(commerceSessionId: String, signature: String) {
        DispatchQueue.main.async {
            self.eventNotifier.post(name: .transactionSent)
        }

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

    func closeCommerceSession(commerceSessionId: String) {
        Task {
            do {
                try await commerceSessionRepository.close(commerceSessionId)
            } catch let error {
                FlexaLogger.commerceSessionLogger.error(error)
            }
        }
    }

    func refreshAccessToken(force: Bool = false) async {
        if shouldRefreshAccessToken || force {
            do {
                try await authStore.refreshToken()
            } catch let error {
                if error.isUnauthorized || error.isRestrictedRegion {
                    eventNotifier.post(name: .flexaAuthorizationError)
                    FlexaIdentity.disconnect()
                }
                FlexaLogger.error(error)
            }
        }
    }

    func purgeIfNeeded() {
        if !userDefaults.bool(forKey: UserDefaults.Key.hasRunBefore.rawValue) {
            FlexaIdentity.disconnect()
            userDefaults.setValue(true, forKey: .hasRunBefore)
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
            guard let self else {
                return
            }
            Task {
                await self.refreshAccessToken()
            }
        }
        timer?.resume()
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    func backgroundRefreshTask() async {
        backgroundRefreshAsyncTask = Task.detached { [weak self] in
            guard let self else {
                return
            }

            await refreshAccessToken()
            guard authStore.isAuthenticated else {
                return
            }

            accountsRepository.backgroundRefresh()
            assetsRepository.backgroundRefresh()
            brandsRepository.backgroundRefresh()

            if !flexaClient.assetAccounts.isEmpty {
                oneTimeKeysRepository.backgroundRefresh()
                exchangeRateRepository.backgroundRefresh()
            }
        }
        await backgroundRefreshAsyncTask?.value
    }
}
