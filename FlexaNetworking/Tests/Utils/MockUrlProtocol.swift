//
//  MockURLResponder.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 03/04/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import XCTest

protocol MockURLResponder {
    static func respond(to request: URLRequest) throws -> (Data?, URLResponse?)
}

class MockURLProtocol<Responder: MockURLResponder>: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        do {
            let (data, urlResponse) = try Responder.respond(to: request)
            let response = try XCTUnwrap(urlResponse)
            client?.urlProtocol(self,
                               didReceive: response,
                               cacheStoragePolicy: .notAllowed
            )
            if let data {
                client?.urlProtocol(self, didLoad: data)
            }
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        // no-op.
    }
}
