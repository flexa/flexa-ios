//
//  AssetsRepository.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

class AssetsRepository: AssetsRepositoryProtocol {
    @Injected(\.flexaNetworkClient) private var networkClient
    @Injected(\.imageLoader) private var imageLoader
    @Injected(\.userDefaults) private var userDefaults

    private(set) var assets: [Asset] {
        get {
            let data: Data? = userDefaults.value(forKey: .assets)

            if let data = data {
                return (try? JSONDecoder().decode([Models.Asset].self, from: data)) ?? []
            } else {
                return []
            }
        }

        set {
            let assetModels = newValue.compactMap { $0 as? Models.Asset }
            try? userDefaults.setValue(JSONEncoder().encode(assetModels), forKey: .assets)
        }
    }

    func refresh() async throws -> [Asset] {
        var output = PaginatedOutput<Models.Asset>()
        var assets: [Models.Asset] = []

        while output.hasMore {
            output = try await networkClient.sendRequest(
                resource: AssetsResource.listAll(limit: nil, startingAfter: assets.last?.id)
            )

            if let data = output.data {
                assets.append(contentsOf: data)
            }
        }

        self.assets = assets
        return assets
    }

    func backgroundRefresh() {
        FlexaLogger.debug("Refreshing Assets")
        Task {
            do {
                let assets = try await refresh()
                imageLoader.loadImages(fromUrls: assets.compactMap { $0.iconUrl })
            } catch let error {
                FlexaLogger.error(error)
            }
        }
    }
}

public extension Array where Element == Asset {
    func findBy(id: String) -> Asset? {
        first { $0.id.caseInsensitiveCompare(id) == .orderedSame }
    }
}
