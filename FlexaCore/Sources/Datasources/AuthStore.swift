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

    private(set) var state: AuthStoreState = .none
    private var refreshTokenAsyncTask: Task<AuthStoreState, Error>?

    var isSignedIn: Bool {
        switch state {
        case .loggedIn:
            return true
        default:
            return false
        }
    }

    var token: Models.Token? {
        tokenData.token
    }

    var email: String? {
        tokenData.email
    }

    @Synchronized private var tokenData: TokenData!

    init() {
        tokenData = keychainHelper.value(forKey: .authToken) ?? TokenData()

        if token != nil {
            state = .loggedIn
        }
    }

    func signIn(with email: String) async throws -> AuthStoreState {
        let verifier = try pkceHelper.generateVerifier()
        let challenge = try pkceHelper.generateChallenge(for: verifier)

        tokenData.token = try await tokensRepository.create(email: email, challenge: challenge)
        tokenData.verifier = verifier
        tokenData.email = email
        saveTokenData()
        self.state = .verifying
        return state
    }

    func verify(code: String?, link: String?) async throws -> AuthStoreState {
        let verifier = try pkceHelper.generateVerifier()
        let challenge = try pkceHelper.generateChallenge(for: verifier)

        tokenData.token = try await tokensRepository.verify(
            tokenId: tokenData.token?.id ?? "",
            verifier: tokenData.verifier,
            challenge: challenge,
            code: code,
            link: link
        )
        tokenData.verifier = verifier
        saveTokenData()
        state = .loggedIn
        return state
    }

    func refreshToken() async throws -> AuthStoreState {
        if refreshTokenAsyncTask == nil {
            let result = try await refreshTokenTask()
            refreshTokenAsyncTask = nil
            return result ?? self.state
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
                    FlexaLogger.error(error)
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

            let verifier = try pkceHelper.generateVerifier()
            let challenge = try pkceHelper.generateChallenge(for: verifier)

            tokenData.token = try await tokensRepository.refresh(
                tokenId: tokenData.token?.id ?? "",
                verifier: tokenData.verifier,
                challenge: challenge
            )

            tokenData.verifier = verifier
            saveTokenData()
            state = .loggedIn
            return state
        }
        return try await refreshTokenAsyncTask?.value
    }
}
