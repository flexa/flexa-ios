//
//  URLRequestExtensions.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 6/6/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public extension URLRequest {
    var cURL: String {
        let cURL = "curl --location"
        let method = "--request \(self.httpMethod ?? "GET")"
        let url = url.flatMap { "'\($0.absoluteString)'" }

        let header = self.allHTTPHeaderFields?
            .map { "--header '\($0): \($1)'" }
            .joined(separator: " ")

        var data: String?
        if let httpBody, !httpBody.isEmpty, let bodyString = String(data: httpBody, encoding: .utf8) {
            let escaped = bodyString
                .replacingOccurrences(of: "'", with: "'\\''")
            data = "--data '\(escaped)'"
        }

        return [cURL, method, url, header, data]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
