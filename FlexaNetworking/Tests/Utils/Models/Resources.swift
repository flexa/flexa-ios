//
//  Resources.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 03/04/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Fakery
@testable import FlexaNetworking

struct TestAPIModel: Codable {
    var name: String
}

struct DefaultTestAPIResource: APIResource {
}

struct TestAPIResource: APIResource {
    var host: String
    var path: String
    var authHeader: String?
    var method: RequestMethod = .get
    var queryParams: [String: String]?
    var headers: [String: String]?
    var defaultHeaders: [String: String]?
    var pathParams: [String: String]?
    var bodyParams: [String: Any]?

    init(host: String = Faker().internet.domainName(),
         path: String = "api",
         method: RequestMethod = .get,
         authHeader: String? = nil,
         headers: [String: String]? = nil,
         defaultHeaders: [String: String]? = nil,
         queryParams: [String: String]? = nil,
         pathParams: [String: String]? = nil,
         bodyParams: [String: Any]? = nil) {
        self.host = host
        self.path = path
        self.authHeader = authHeader
        self.headers = headers
        self.defaultHeaders = defaultHeaders
        self.method = method
        self.queryParams = queryParams
        self.pathParams = pathParams
        self.bodyParams = bodyParams
    }
}
