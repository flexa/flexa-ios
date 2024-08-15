//
//  URLSession.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 03/04/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension URLSession {
    convenience init<T: MockURLResponder>(mockResponder: T.Type) {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol<T>.self]
        self.init(configuration: config)
        URLProtocol.registerClass(MockURLProtocol<T>.self)
    }
}
