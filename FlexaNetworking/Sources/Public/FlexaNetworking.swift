//
//  FlexaNetworking.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 01/26/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import WebKit

public enum NetworkError: Error {
    case custom(_ error: Error, URLRequest?)
    case decode(_ error: Error?)
    case invalidRequest
    case invalidResponse(URLRequest?)
    case missingData(URLRequest?)
    case invalidStatus(status: Int, resource: APIResource, request: URLRequest?, data: Data?)
    case unknown(URLRequest?)

    static let unauthorizedStatusCode = 401
    static let notFoundStatusCode = 404
    static let forbiddenStatusCode = 403

    public var isUnauthorized: Bool {
        isStatusCode(Self.unauthorizedStatusCode)
    }

    public var isNotFound: Bool {
        isStatusCode(Self.notFoundStatusCode)
    }

    public var isForbidden: Bool {
        isStatusCode(Self.forbiddenStatusCode)
    }

    public static func unauthorizedError(for resource: APIResource) -> NetworkError {
        .invalidStatus(status: unauthorizedStatusCode, resource: resource, request: nil, data: nil)
    }

    private func isStatusCode(_ statusCode: Int) -> Bool {
        if case .invalidStatus(let status, _, _, _) = self, status == statusCode {
            return true
        }
        return false
    }
}

public enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public protocol APIResource {
    var authHeader: String? { get }
    var port: Int? { get }
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var defaultHeaders: [String: String]? { get }
    var headers: [String: String]? { get }
    var queryParams: [String: String]? { get }
    var pathParams: [String: String]? { get }
    var bodyParams: [String: Any]? { get }
}

public protocol Networkable {
    func sendRequest(resource: any APIResource) async throws
    func sendRequest<T: Decodable>(resource: any APIResource) async throws -> T
    func sendRequest<T: Decodable>(resource: any APIResource) async -> (T?, HTTPURLResponse?, Error?)
}
