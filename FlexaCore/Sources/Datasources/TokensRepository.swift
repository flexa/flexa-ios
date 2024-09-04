//
//  TokensRepository.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 3/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

protocol TokensRepositoryProtocol {
    func create(email: String, challenge: String) async throws -> Models.Token
    func refresh(tokenId: String, verifier: String, challenge: String) async throws -> Models.Token
    func delete(tokenId: String) async throws
    func verify(tokenId: String,
                verifier: String,
                challenge: String,
                code: String?,
                link: String?
    ) async throws -> Models.Token
}

class TokensRepository: TokensRepositoryProtocol {
    @Injected(\.networkClient) var networkClient

    func create(email: String, challenge: String) async throws -> Models.Token {
        try await sendRequest(
            resource: TokensResource.create(
                CreateTokenInput(email: email, challenge: challenge)
            )
        )
    }

    func verify(tokenId: String,
                verifier: String,
                challenge: String,
                code: String?,
                link: String?
    ) async throws -> Models.Token {
        let resource = TokensResource.verify(
            tokenId,
            VerifyTokenInput(
                verifier: verifier,
                challenge: challenge,
                code: code,
                link: link
            )

        )
        return try await sendRequest(resource: resource)
    }

    func delete(tokenId: String) async throws {
        try await sendRequest(resource: TokensResource.delete(tokenId))
    }

    func refresh(tokenId: String, verifier: String, challenge: String) async throws -> Models.Token {
        let resource = TokensResource.refresh(
            tokenId,
            RefreshTokenInput(
                verifier: verifier,
                challenge: challenge
            )
        )
        return try await sendRequest(resource: resource)
    }

    private func sendRequest(resource: TokensResource) async throws {
        do {
            try await networkClient.sendRequest(resource: resource)
        } catch let error {
            throw resource.wrappingError(error) ?? error
        }
    }

    private func sendRequest<T: Decodable>(resource: TokensResource) async throws -> T {
        do {
            return try await networkClient.sendRequest(resource: resource)
        } catch let error {
            throw resource.wrappingError(error) ?? error
        }
    }
}
