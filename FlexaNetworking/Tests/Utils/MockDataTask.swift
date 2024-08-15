//
//  MockDataTask.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 6/9/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

class MockDataTask: URLSessionDataTask {
    let mockResponse: URLResponse?

    init(response: URLResponse?) {
        mockResponse = response
        super.init()
    }

    override var response: URLResponse? {
        mockResponse
    }
}
