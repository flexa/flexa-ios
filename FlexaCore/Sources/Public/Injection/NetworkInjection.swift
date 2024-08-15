//
//  NetworkInjection.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 4/24/23.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import Factory
import FlexaNetworking

public extension Container {
    private var imageURLCache: Factory<URLCache> {
        self {
            URLCache(memoryCapacity: 5 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: "cached_images")
        }.singleton
    }

    private var imageUrlSessionConfiguration: Factory<URLSessionConfiguration> {
        self {
            let config = URLSessionConfiguration.default
            config.urlCache = self.imageURLCache()
            return config
        }.singleton
    }

    var imageUrlSession: Factory<URLSession> {
        self {
            URLSession(configuration: self.imageUrlSessionConfiguration())
        }.singleton
    }

    var imageLoader: Factory<ImageLoader> {
        self {
            CacheImageLoader()
        }.singleton
    }
}
