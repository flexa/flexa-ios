//
//  FlexaAPIResource.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 4/23/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import FlexaNetworking
import Factory
import Foundation
import DeviceKit

protocol Authenticable {
    var authToken: String? { get }
}

protocol FlexaAPIResource: APIResource, Authenticable {
}

extension FlexaAPIResource {
    var authHeader: String? {
        guard let authToken else {
            return nil
        }
        return "Basic \(authToken)"
    }

    var scheme: String {
        "https"
    }

    var host: String {
        customHost.isEmpty ? "api.flexa.co" : customHost
    }

    var method: RequestMethod {
        .get
    }

    var defaultHeaders: [String: String]? {
        [
            "Content-Type": "application/json",
            "Accept": "application/vnd.flexa+json",
            "Flexa-App": Bundle.applicationDisplayName,
            "User-Agent": userAgent,
            "Client-Trace-Id": UUID().uuidString
        ]
    }

    func paginationParams(limit: Int? = nil, startingAfter: String? = nil, query: String? = nil) -> [String: String] {
        var dictionary: [String: String] = [
            "limit": String(limit ?? 100)
        ]

        if let startingAfter {
            dictionary["starting_after"] = startingAfter
        }

        if let query {
            dictionary["query"] = query
        }
        return dictionary
    }

    private var userAgent: String {
        let osVersion = Device.current.systemVersion ?? "unknown"
        return "iOS/\(osVersion) Flexa/\(Flexa.version) \(Bundle.applicationBundleId)/\(Bundle.applicationVersion)"
    }

    private var customHost: String {
        UserDefaults.standard.value(forKey: .apiHost) ?? ""
    }
}

protocol PublishableKeyAuthenticable: Authenticable {
}

extension PublishableKeyAuthenticable {
    var authToken: String? {
        let publishableKey = Container.shared.flexaClient().publishableKey
        return Data((":" + publishableKey).utf8).base64EncodedString()
    }
}

protocol JWTAuthenticable: Authenticable {
}

extension JWTAuthenticable {
    var authToken: String? {
        guard let jwt = Container.shared.authStore().token?.value else {
            FlexaLogger.info("JWT not available")
            return nil
        }
        return Data((":" + jwt).utf8).base64EncodedString()
    }
}

struct DefaultJWTAuthenticable: JWTAuthenticable {
}

struct DefaultPublishableKeyAuthenticable: PublishableKeyAuthenticable {
}
