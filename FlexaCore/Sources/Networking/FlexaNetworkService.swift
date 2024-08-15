//
//  FlexaNetworkService.swift
//
//  Created by Rodrigo Ordeix on 17/6/24.
//

import UIKit
import FlexaNetworking
import Factory

class FlexaNetworkService: Networkable {
    @Injected(\.networkClient) var networkClient
    @Injected(\.authStore) var authStore

    typealias ResponseTuple<T> = (T?, HTTPURLResponse?, Error?) where T: Decodable

    func sendRequest(resource: any FlexaNetworking.APIResource) async throws {
        let (_, _, error) = await sendRequest(resource: resource) as (Data?, HTTPURLResponse?, Error?)

        if let error {
            throw error
        }
    }

    func sendRequest<T>(resource: APIResource) async throws -> T where T: Decodable {
        var object: T?
        var error: Error?

        (object, _, error) = await sendRequest(resource: resource)

        if let error {
            throw error
        }

        guard let object else {
            throw NetworkError.decode(nil)
        }

        return object
    }

    func sendRequest<T>(resource: APIResource) async -> ResponseTuple<T> {
        await sendRequest(resource: resource, refreshTokenOnFailure: true)
    }

    func sendRequest<T>(resource: APIResource,
                        refreshTokenOnFailure: Bool) async -> ResponseTuple<T> {

        var object: T?
        var response: HTTPURLResponse?
        var error: Error?

        if let token = authStore.token, token.isExpired {
            _ = try? await authStore.refreshToken()
        }

        (object, response, error) = await networkClient.sendRequest(resource: resource)

        guard let error else {
            return (object, response, error)
        }

        guard refreshTokenOnFailure else {
            return (nil, nil, error)
        }

        return await refreshAndRetry(resource: resource, error: error)
    }

    func refreshAndRetry<T>(resource: APIResource, error: Error) async -> ResponseTuple<T> {
        if let token = authStore.token, token.isExpired {
            return await refreshTokenAndSendRequest(resource: resource, error: error)
        } else if error.shouldRetry {
            return await refreshTokenAndSendRequest(resource: resource, error: error)
        } else {
            return (nil, nil, error)
        }
    }

    func refreshTokenAndSendRequest<T>(resource: APIResource, error: Error) async -> ResponseTuple<T> {
        do {
            _ = try await authStore.refreshToken()
        } catch let error {
            FlexaLogger.error(error)
        }

        if authStore.isSignedIn {
            return await sendRequest(resource: resource, refreshTokenOnFailure: false)
        } else {
            return (nil, nil, NetworkError.unauthorizedError(for: resource))
        }
    }
}

private extension Error {
    var shouldRetry: Bool {
        guard let error = self as? NetworkError else {
            return false
        }
        return error.isForbidden || error.isUnauthorized || error.isNotFound
    }
}
