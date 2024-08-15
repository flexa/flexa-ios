//
//  NetworkService.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 01/26/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

public final class NetworkService: Networkable {
    @Injected(\.urlSession) private var session

    public init() {
    }

    public func sendRequest(resource: any APIResource) async throws {
        let (_, _, error) = await sendRequest(resource: resource) as (Data?, HTTPURLResponse?, Error?)

        if let error {
            throw error
        }
    }

    public func sendRequest<T>(resource: any APIResource) async throws -> T where T: Decodable {
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

    public func sendRequest<T>(resource: any APIResource) async -> (T?, HTTPURLResponse?, Error?) where T: Decodable {

        guard let request = resource.request, request.url?.absoluteString != nil else {
            return (nil, nil, NetworkError.invalidRequest)
        }

        var data: Data
        var urlResponse: URLResponse?

        do {
            (data, urlResponse) = try await session.data(for: request)
        } catch let error {
            return (nil, nil, error)
        }

        guard let response = urlResponse as? HTTPURLResponse else {
            return (nil, nil, NetworkError.invalidResponse)
        }

        guard 200...299 ~= response.statusCode else {
            let error = NetworkError.invalidStatus(
                status: response.statusCode,
                resource: resource
            )
            return (nil, response, error)
        }

        if T.self == Data.self {
            return (data as? T, response, nil)
        }

        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            return (object, response, nil)
        } catch let decodeError {
            let error = NetworkError.decode(decodeError)
            return (nil, response, error)
        }
    }
}
