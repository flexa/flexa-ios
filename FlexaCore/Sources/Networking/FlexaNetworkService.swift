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
    @Injected(\.eventNotifier) var eventNotifier

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
            let error = NetworkError.decode(nil)
            throw wrapError(error, resource: resource) ?? error
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

        guard resource.authHeader != nil else {
            return signOut(resource)
        }

        if let token = authStore.token, token.isExpired {
            _ = try? await authStore.refreshToken()
        }

        (object, response, error) = await networkClient.sendRequest(resource: resource)

        guard let error else {
            Flexa.canSpend = true
            return (object, response, error)
        }

        guard !error.isRestrictedRegion else {
            Flexa.canSpend = false
            return (nil, nil, error)
        }

        Flexa.canSpend = true

        guard refreshTokenOnFailure else {
            return (nil, nil, wrapError(error, resource: resource))
        }

        return await refreshAndRetry(resource: resource, error: error)
    }

    func refreshAndRetry<T>(resource: APIResource, error: Error) async -> ResponseTuple<T> {
        var resourceAllowRetry: Bool {
            guard let flexaApiResource = resource as? FlexaAPIResource else {
                return true
            }
            return flexaApiResource.allowRetry
        }

        guard resourceAllowRetry else {
            return (nil, nil, wrapError(error, resource: resource))
        }

        if let token = authStore.token, token.isExpired {
            return await refreshTokenAndSendRequest(resource: resource, error: error)
        } else if error.shouldRetry {
            return await refreshTokenAndSendRequest(resource: resource, error: error)
        } else {
            return (nil, nil, wrapError(error, resource: resource))
        }
    }

    func refreshTokenAndSendRequest<T>(resource: APIResource, error: Error) async -> ResponseTuple<T> {
        var refreshTokenError: Error?
        do {
           try await authStore.refreshToken()
        } catch let error {
            refreshTokenError = error
            FlexaLogger.error(error)
        }

        if let refreshTokenError, refreshTokenError.isRestrictedRegion {
            return (nil, nil, refreshTokenError)
        } else if let refreshTokenError, refreshTokenError.isUnauthorized {
            return signOut(resource)
        } else if authStore.isSignedIn {
                return await sendRequest(resource: resource, refreshTokenOnFailure: false)
        }
        return (nil, nil, error)
    }

    private func signOut<T>(_ resource: APIResource) -> ResponseTuple<T> {
        FlexaIdentity.disconnect()
        eventNotifier.post(name: .flexaAuthorizationError)
        return (nil, nil, NetworkError.unauthorizedError(for: resource))
    }

    private func wrapError(_ error: Error?, resource: APIResource) -> Error? {
        if let networkError = error as? NetworkError, networkError.isRestrictedRegion || networkError.isUnauthorized {
                return ReasonableError.custom(error: networkError)
        }

        guard let flexaResource = resource as? FlexaAPIResource else {
            return error
        }
        return flexaResource.wrappingError(error)
    }
}

private extension Error {
    var shouldRetry: Bool {
        guard let error = self as? NetworkError else {
            return false
        }
        return (error.isForbidden && !error.isRestrictedRegion) || error.isUnauthorized || error.isNotFound
    }
}

private extension NetworkError {
    var traceId: String? {
        switch self {
        case .custom(_, let request),
                .invalidResponse(let request),
                .missingData(let request),
                .invalidStatus(_, _, let request, _),
                .unknown(let request):
            return request?.value(forHTTPHeaderField: "Client-Trace-Id")
        default:
            return nil
        }
    }
}
