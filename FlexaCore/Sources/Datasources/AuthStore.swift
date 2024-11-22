//
//  AuthStore.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 12/12/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import Factory
import UIKit

enum AuthStoreState {
    case loggedIn
    case verifying
    case none
}

protocol AuthStoreProtocol {
    var email: String? { get }
    var token: Models.Token? { get }
    var state: AuthStoreState { get }
    var isSignedIn: Bool { get }
    var isAuthenticated: Bool { get }

    func signIn(with email: String) async throws -> AuthStoreState
    func verify(code: String?, link: String?) async throws -> AuthStoreState

    @discardableResult
    func refreshToken() async throws -> AuthStoreState
    func refreshTokenIfNeeded() async throws -> AuthStoreState
    func signOut()
    func purgeIfNeeded()
}

private struct TokenData: FlexaModelProtocol {
    var token: Models.Token?
    var email: String = ""
    var verifier: String = ""
}

final class AuthStore: AuthStoreProtocol {
    @Injected(\.keychainHelper) private var keychainHelper
    @Injected(\.userDefaults) private var userDefaults
    @Injected(\.tokensRepository) private var tokensRepository
    @Injected(\.pkceHelper) private var pkceHelper

    @Synchronized private var refreshTokenAsyncTask: Task<AuthStoreState, Error>?
    @Synchronized private var refreshingToken = false
    @Synchronized private var tokenData: TokenData!

    private(set) var state: AuthStoreState = .none
    private let logger = FlexaLogger.authLogger
    private let serialQueue = DispatchQueue(label: "co.flexa.sdk-refreshTokenQueue")
    private let refreshSemaphore = DispatchSemaphore(value: 1)

    var isSignedIn: Bool {
        switch state {
        case .loggedIn:
            return true
        default:
            return false
        }
    }

    var isAuthenticated: Bool {
        guard let token, isSignedIn, token.isActive, !token.isExpired else {
            return false
        }
        return true
    }

    var token: Models.Token? {
        tokenData.token
    }

    var email: String? {
        tokenData.email
    }

    init() {
        tokenData = keychainHelper.value(forKey: .authToken) ?? TokenData()

        if token != nil {
            state = .loggedIn
        }
    }

    func signIn(with email: String) async throws -> AuthStoreState {
        let verifier = try pkceHelper.generateVerifier()
        let challenge = try pkceHelper.generateChallenge(for: verifier)

        var tokenData = TokenData()
        tokenData.token = try await tokensRepository.create(email: email, challenge: challenge)
        tokenData.verifier = verifier
        tokenData.email = email

        self.tokenData = tokenData
        saveTokenData()
        self.state = .verifying
        return state
    }

    func verify(code: String?, link: String?) async throws -> AuthStoreState {
        let verifier = try pkceHelper.generateVerifier()
        let challenge = try pkceHelper.generateChallenge(for: verifier)

        var tokenData = self.tokenData ?? TokenData()
        tokenData.token = try await tokensRepository.verify(
            tokenId: tokenData.token?.id ?? "",
            verifier: tokenData.verifier,
            challenge: challenge,
            code: code,
            link: link
        )
        tokenData.verifier = verifier

        self.tokenData = tokenData
        saveTokenData()
        state = .loggedIn
        return state
    }

    func refreshToken() async throws -> AuthStoreState {
        if !refreshingToken {
            refreshingToken = true
            do {
                let result = try await refreshTokenTask()
                refreshTokenAsyncTask = nil
                refreshingToken = false
                return result ?? self.state
            } catch let error {
                refreshTokenAsyncTask = nil
                refreshingToken = false
                throw error
            }
        }
        return try await refreshTokenAsyncTask?.value ?? self.state
    }

    func refreshTokenIfNeeded() async throws -> AuthStoreState {
        if let token = tokenData.token, token.isActive, !token.isExpired {
            state = .loggedIn
            return state
        }
        return try await refreshToken()
    }

    func signOut() {
        Task {
            if let tokenId = tokenData.token?.id {
                do {
                    try await tokensRepository.delete(tokenId: tokenId)
                } catch let error {
                    logger.error(error)
                }
            }

            tokenData = TokenData()
            state = .none
            saveTokenData()
        }
    }

    func purgeIfNeeded() {
    }

    private func saveTokenData() {
        keychainHelper.setValue(tokenData, forKey: .authToken)
    }

    private func refreshTokenTask() async throws -> AuthStoreState? {
        refreshTokenAsyncTask = Task { () -> AuthStoreState in
            guard isSignedIn, token != nil else {
                state = .none
                return state
            }

            return try await withCheckedThrowingContinuation { continuation in
                serialQueue.async {
                    self.refreshSemaphore.wait()
                    Task {
                        do {
                            let verifier = try self.pkceHelper.generateVerifier()
                            let challenge = try self.pkceHelper.generateChallenge(for: verifier)

                            var tokenData = self.tokenData ?? TokenData()
                            tokenData.token = try await self.tokensRepository.refresh(
                                tokenId: tokenData.token?.id ?? "",
                                verifier: tokenData.verifier,
                                challenge: challenge
                            )
                            tokenData.verifier = verifier

                            self.tokenData = tokenData
                            self.saveTokenData()
                            self.state = .loggedIn
                            continuation.resume(returning: self.state)
                        } catch let error {
                            continuation.resume(throwing: error)
                        }
                        self.refreshSemaphore.signal()
                    }
                }
            }
        }
        return try await refreshTokenAsyncTask?.value
    }
}
