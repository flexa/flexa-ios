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
    @Injected(\.exchangeRatesRepository) var exchangeRateRepository
    @Injected(\.authStore) var authStore
    @Injected(\.eventNotifier) var eventNotifier
    @Injected(\.flexaClient) var flexaClient

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
        backgroundRefresh()
    }

    @objc func appDidEnterBackground() {
        stopTimer()
    }

    func backgroundRefresh() {
        Task {
            await refreshAccessToken(force: true)
            guard authStore.isSignedIn else {
                return
            }

            accountsRepository.backgroundRefresh()
            assetsRepository.backgroundRefresh()
            brandsRepository.backgroundRefresh()

            if !flexaClient.appAccounts.isEmpty {
                appAccountsRepository.backgroundRefresh()
                exchangeRateRepository.backgroundRefresh()
            }
        }

        startTimer()
    }

    func refresh() async {
        guard authStore.isSignedIn else {
            return
        }
        do {
            try await accountsRepository.refresh()
            try await assetsRepository.refresh()
            try await brandsRepository.refresh()
            try await brandsRepository.refreshLegacyFlexcodeBrands()

            if !flexaClient.appAccounts.isEmpty {
                try await appAccountsRepository.refresh()
            }
        } catch let error {
            FlexaLogger.error(error)
        }
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

    func refreshAccessToken(force: Bool = false) async {
        if shouldRefreshAccessToken || force {
            do {
                try await authStore.refreshToken()
            } catch let error {
                if error.isUnauthorized {
                    eventNotifier.post(name: .flexaAuthorizationError)
                }
                FlexaLogger.error(error)
            }
        }
    }
}
