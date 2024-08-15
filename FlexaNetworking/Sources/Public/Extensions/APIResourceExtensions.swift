//
//  APIResourceExtensions.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 01/26/24.
//  Copyright © 2024 Flexa. All rights reserved.
//
import Foundation

public extension APIResource {
    var authHeader: String? {
        nil
    }

    var scheme: String {
        "https"
    }

    var host: String {
        ""
    }

    var path: String {
        ""
    }

    var port: Int? {
        nil
    }

    var method: RequestMethod {
        .get
    }

    var defaultHeaders: [String: String]? {
        nil
    }

    var headers: [String: String]? {
        nil
    }

    var queryParams: [String: String]? {
        nil
    }

    var pathParams: [String: String]? {
        nil
    }

    var bodyParams: [String: Any]? {
        nil
    }

    var queryItems: [URLQueryItem]? {
        queryParams?.map { URLQueryItem(name: $0.0, value: $0.1) }
    }

    var request: URLRequest? {
        guard let url = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        var requestHeaders = self.defaultHeaders

        if let headers, !headers.isEmpty {
            requestHeaders = requestHeaders ?? [:]
            headers.forEach { key, value in
                requestHeaders?[key] = value
            }
        }

        if let authHeader {
            requestHeaders = requestHeaders ?? [:]
            requestHeaders?["Authorization"] = authHeader
        }

        request.allHTTPHeaderFields = requestHeaders
        request.httpBody = bodyParams?.data
        return request
    }

    private var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.port = port
        components.host = host
        components.queryItems = queryItems
        components.path = (path.starts(with: "/") ? path : "/\(path)").replacingOccurrences(of: pathParams ?? [:])
        return components
    }
}

extension String {
    func replacingOccurrences(of dictionary: [String: String]) -> String {
        var replacedString = self
        dictionary.forEach { (key, value) in
            replacedString = replacedString.replacingOccurrences(of: key, with: value)
        }
        return replacedString
    }
}

extension Dictionary {
    var data: Data? {
        try? JSONSerialization.data(withJSONObject: self)
    }
}
