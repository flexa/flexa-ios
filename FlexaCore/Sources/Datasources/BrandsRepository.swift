//
//  BrandsRepository.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

class BrandsRepository: BrandsRepositoryProtocol {
    @Injected(\.flexaNetworkClient) private var networkClient
    @Injected(\.userDefaults) private var userDefaults: UserDefaults
    @Injected(\.imageLoader) private var imageLoader

    private let minSyncInterval: TimeInterval = 5 * 60
    private var lastSyncedAt: TimeInterval?
    private var legacyLastSyncedAt: TimeInterval?

    @Synchronized private var refreshAsyncTask: Task<[Brand], Error>?
    @Synchronized private var refreshLegacyAsyncTask: Task<[Brand], Error>?

    var all: [Brand] {
        get {
            let values: [Models.Brand] = userDefaults.getDecodedValue(forKey: .brands) ?? []
            return values
        }
        set {
            userDefaults.setEncodedValue(newValue as? [Models.Brand], forKey: .brands)
        }
    }

    var legacyFlexcodeBrands: [Brand] {
        get {
            let values: [Models.Brand] = userDefaults.getDecodedValue(forKey: .legacyBrands) ?? []
            return values
        }
        set {
            userDefaults.setEncodedValue(newValue as? [Models.Brand], forKey: .legacyBrands)
        }
    }

    var pinnedBrandIds: [String] {
        get {
            userDefaults.getDecodedValue(forKey: .pinnedBrandIds) ?? []
        }
        set {
            userDefaults.setEncodedValue(newValue, forKey: .pinnedBrandIds)
        }
    }

    func pinBrand(_ brand: Brand) {
        guard !pinnedBrandIds.contains(where: { $0 == brand.id }) else {
            return
        }

        pinnedBrandIds += [brand.id]
    }

    func unpinBrand(_ brand: Brand) {
        pinnedBrandIds = pinnedBrandIds.filter { $0 != brand.id }
    }

    func movePinnedBrand(from source: IndexSet, to destination: Int) {
        var brandIds = pinnedBrandIds
        brandIds.move(fromOffsets: source, toOffset: destination)
        pinnedBrandIds = brandIds
    }

    @discardableResult
    func refresh() async throws -> [Brand] {
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
        return try await refreshAsyncTask?.value ?? self.all
    }

    @discardableResult
    func refreshLegacyFlexcodeBrands() async throws -> [Brand] {
        if refreshLegacyAsyncTask == nil {
            do {
                let result = try await refreshLegacyTask()
                refreshLegacyAsyncTask = nil
                return result
            } catch let error {
                refreshLegacyAsyncTask = nil
                throw error
            }
        }
        return try await refreshLegacyAsyncTask?.value ?? self.legacyFlexcodeBrands
    }

    func backgroundRefresh() {
        Task {
            do {
                if shouldSync {
                    let brands = try await refresh()
                    imageLoader.loadImages(fromUrls: brands.compactMap { $0.logoUrl })
                }
            } catch let error {
                FlexaLogger.error(error)
            }

            do {
                if shouldSyncLegacy {
                    try await refreshLegacyFlexcodeBrands()
                }
            } catch let error {
                FlexaLogger.error(error)
            }
        }
    }
}

private extension BrandsRepository {
    private var shouldSync: Bool {
        guard refreshAsyncTask == nil else {
            return false
        }

        guard let lastSyncedAt else {
            return true
        }

        return lastSyncedAt + minSyncInterval <= Date.now.timeIntervalSince1970
    }

    private var shouldSyncLegacy: Bool {
        guard refreshLegacyAsyncTask == nil else {
            return false
        }

        guard let legacyLastSyncedAt else {
            return true
        }

        return legacyLastSyncedAt + minSyncInterval <= Date.now.timeIntervalSince1970
    }

    private func refreshTask() async throws -> [Brand] {
        refreshAsyncTask = Task { () -> [Brand] in
            try await getAllBrands()
        }
        return try await refreshAsyncTask?.value ?? self.all
    }

    private func getAllBrands() async throws -> [Brand] {
        var output = PaginatedOutput<Models.Brand>()
        var brands: [Models.Brand] = []

        while output.hasMore {
            output = try await networkClient.sendRequest(
                resource: BrandsResource.listAll(limit: nil, startingAfter: brands.last?.id)
            )
            if let data = output.data {
                brands.append(contentsOf: data)
            }
        }
        lastSyncedAt = Date.now.timeIntervalSince1970
        all = brands
        return brands
    }

    private func refreshLegacyTask() async throws -> [Brand] {
        refreshLegacyAsyncTask = Task { () -> [Brand] in
            try await getLegacyBrands()
        }
        return try await refreshLegacyAsyncTask?.value ?? self.legacyFlexcodeBrands
    }

    private func getLegacyBrands() async throws -> [Brand] {
        var output = PaginatedOutput<Models.Brand>()
        var brands: [Models.Brand] = []

        while output.hasMore {
            output = try await networkClient.sendRequest(
                resource: BrandsResource.listLegacy(limit: nil, startingAfter: brands.last?.id)
            )
            if let data = output.data {
                brands.append(contentsOf: data)
            }
        }

        legacyLastSyncedAt = Date.now.timeIntervalSince1970
        legacyFlexcodeBrands = brands
        return brands
    }
}
