//
//  ImageLoader.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/23/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import UIKit
import Factory

public protocol ImageLoader {
    func cachedData(forUrl url: URL) -> Data?
    func loadData(fromUrl url: URL, forceRefresh: Bool) async -> Data?
    func cachedImage(forUrl url: URL) -> UIImage?
    func loadImage(fromUrl url: URL, forceRefresh: Bool) async -> UIImage?
}

public extension ImageLoader {
    func loadImage(fromUrl url: URL) async -> UIImage? {
        await loadImage(fromUrl: url, forceRefresh: false)
    }

    func loadImage(fromUrlString urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        return await loadImage(fromUrl: url)
    }

    func loadImages(fromUrls urls: [URL], forceRefresh: Bool = true) {
        urls.forEach { url in
            Task.detached {
                await loadImage(fromUrl: url, forceRefresh: forceRefresh)
            }
        }
    }
}

public struct CacheImageLoader: ImageLoader {
    @Injected(\.imageUrlSession) var urlSession

    public init() {
    }

    public func cachedData(forUrl url: URL) -> Data? {
        guard let response = urlSession.configuration.urlCache?.cachedResponse(for: URLRequest(url: url)) else {
            return nil
        }
        return response.data
    }

    public func loadData(fromUrl url: URL, forceRefresh: Bool) async -> Data? {
        return try? await withCheckedThrowingContinuation { continuation in
            let request = URLRequest(
                url: url,
                cachePolicy: forceRefresh ? .reloadIgnoringLocalAndRemoteCacheData : .useProtocolCachePolicy
            )

            let task = self.urlSession.dataTask(with: request) { data, response, error in
                if let data,
                   let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    continuation.resume(returning: data)
                } else {
                    // We may want to throw an error here, or just return nil
                    if let error {
                        print(error)
                    }
                    continuation.resume(returning: nil)
                }
            }
            task.resume()
        }
    }

    public func cachedImage(forUrl url: URL) -> UIImage? {
        guard let data = cachedData(forUrl: url) else {
            return nil
        }
        return UIImage(data: data)
    }

    public func loadImage(fromUrl url: URL, forceRefresh: Bool) async -> UIImage? {
        guard let data = await loadData(fromUrl: url, forceRefresh: forceRefresh) else {
            return nil
        }
        return UIImage(data: data)
    }
}
