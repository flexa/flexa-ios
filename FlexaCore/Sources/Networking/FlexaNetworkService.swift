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

    private let retryQueue = DispatchQueue(label: "co.flexa.sdk-networkRetry")
    private var retryInterval: TimeInterval {
        TimeInterval.random(in: 1..<5)
    }

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
                        retryOnInvalidtoken: Bool = true,
                        refreshTokenOnFailure: Bool) async -> ResponseTuple<T> {

        var object: T?
        var response: HTTPURLResponse?
        var error: Error?

        // No auth header, just sign the user out
        guard resource.authHeader != nil else {
            return signOut(resource)
        }

        // If the token is expired before performing the request we need to refresh it
        if let token = authStore.token, token.isExpired {
            _ = try? await authStore.refreshToken()
        }

        (object, response, error) = await networkClient.sendRequest(resource: resource)

        // Successful response, it's running on a supported location, just return the result
        guard let error else {
            Flexa.canSpend = true
            return (object, response, error)
        }

        // It's a restricted region, disable the SDK usage
        guard !error.isRestrictedRegion else {
            Flexa.canSpend = false
            return (nil, nil, error)
        }

        // There was an error but it's running on a supported location, allow to use the SDK
        Flexa.canSpend = true

        // If the token is invalid it could have been refreshed while this request was traveling to the server, just retry once, with the existing token, after a random time.
        if retryOnInvalidtoken && error.isUnauthorized {
            FlexaLogger.info("Unauthorized response. Retry after interval")
            return await retry(resource: resource, refreshTokenOnFailure: refreshTokenOnFailure, error: error)
        }

        // If the token is not expired or refresh is disabled, return the rror
        guard error.isExpiredToken && refreshTokenOnFailure else {
            return (nil, nil, wrapError(error, resource: resource))
        }

        // If the token is expired then refresh and retry if refreshTokenOnFailure is true
        return await refreshAndRetry(resource: resource, error: error)
    }

    func retry<T>(resource: APIResource, refreshTokenOnFailure: Bool, error: Error) async -> ResponseTuple<T> {
        await withCheckedContinuation { continuation in
            retryQueue.asyncAfter(deadline: .now() + retryInterval) {
                Task {
                    let result: ResponseTuple<T> = await self.sendRequest(
                        resource: resource,
                        retryOnInvalidtoken: false,
                        refreshTokenOnFailure: refreshTokenOnFailure
                    )
                    continuation.resume(returning: result)
                }
            }
        }
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
