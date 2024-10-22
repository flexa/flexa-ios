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
    @Injected(\.flexaClient) private var flexaClient

    private var lastSyncedAt: TimeInterval?
    private let minSyncInterval: TimeInterval = 5 * 60
    @Synchronized private var refreshAsyncTask: Task<[Asset], Error>?

    private var shouldSync: Bool {
        guard refreshAsyncTask == nil else {
            return false
        }

        guard let lastSyncedAt else {
            return true
        }

        return lastSyncedAt + minSyncInterval <= Date.now.timeIntervalSince1970
    }

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

    var availableClientAssets: [Asset] {
        let ids = flexaClient.assetAccounts
            .flatMap { $0.availableAssets }
            .map { $0.assetId }

        return assets.filter { ids.contains($0.id) }
    }

    func refresh() async throws -> [Asset] {
        if refreshAsyncTask == nil {
            do {
                let result = try await refreshTask()
                refreshAsyncTask = nil
                return result
            } catch let error {
                refreshAsyncTask = nil
                throw error
            }
        }
        return try await refreshAsyncTask?.value ?? self.assets
    }

    func backgroundRefresh() {
        guard shouldSync else {
            return
        }
        Task {
            do {
                let assets = try await refresh()
                imageLoader.loadImages(fromUrls: assets.compactMap { $0.iconUrl })
            } catch let error {
                FlexaLogger.error(error)
            }
        }
    }

    private func refreshTask() async throws -> [Asset] {
        refreshAsyncTask = Task { () -> [Asset] in
            try await getAssets()
        }
        return try await refreshAsyncTask?.value ?? self.assets
    }

    private func getAssets() async throws -> [Asset] {
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
        self.lastSyncedAt = Date.now.timeIntervalSince1970
        self.assets = assets
        return assets
    }
}

public extension Array where Element == Asset {
    func findBy(id: String) -> Asset? {
        first { $0.id.caseInsensitiveCompare(id) == .orderedSame }
    }
}
