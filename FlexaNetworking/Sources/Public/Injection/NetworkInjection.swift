//
//  NetworkInjection.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 01/26/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

public extension Container {
    var urlSessionConfiguration: Factory<URLSessionConfiguration> {
        self { .ephemeral }
    }

    var sseUrlSessionConfiguration: ParameterFactory<(String?, TimeInterval), URLSessionConfiguration> {
        self { lastEventId, timeout in
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = [
                "Accept": "text/event-stream",
                "Cache-Control": "no-cache"
            ]

            if let lastEventId {
                configuration.httpAdditionalHeaders?["Last-Event-ID"] = lastEventId
            }

            configuration.timeoutIntervalForRequest = timeout
            configuration.timeoutIntervalForResource = timeout

            return configuration
        }
    }

    var urlSession: Factory<URLSession> {
        self { URLSession(configuration: self.urlSessionConfiguration()) }
    }

    var sseUrlSession: ParameterFactory<(String?, TimeInterval, URLSessionDelegate?), URLSession> {
        self { lastEventId, timeout, delegate in
            let configuration = self.sseUrlSessionConfiguration((lastEventId, timeout))
            return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        }
    }

    var networkClient: Factory<Networkable> {
        self { NetworkService() }
    }

    var sseClient: ParameterFactory<(APIResource, TimeInterval), SSEClientProtocol?> {
        self { resource, timeoutInterval in
            SSEClient(resource: resource, timeoutInterval: timeoutInterval)
        }
    }
}
