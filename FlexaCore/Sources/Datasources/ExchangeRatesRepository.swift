//
//  ExchangeRatesRepository.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 9/27/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

class ExchangeRatesRepository: ExchangeRatesRepositoryProtocol {
    @Injected(\.flexaNetworkClient) private var networkClient
    @Injected(\.userDefaults) private var userDefaults
    @Injected(\.flexaClient) private var flexaClient
    @Injected(\.assetsRepository) private var assetsRepository

    private var lastSyncedAt: TimeInterval?
    private let maxAssetIds = 20
    private let minSyncInterval: TimeInterval = 20
    @Synchronized private var getAsyncTask: Task<[ExchangeRate], Error>?

    private var assetIdsToRefresh: [String] {
        assetIds()
    }

    private var shouldBackgroundSync: Bool {
        guard getAsyncTask == nil else {
            return false
        }
        return shouldSync
    }

    private var shouldSync: Bool {
        guard let lastSyncedAt else {
            return true
        }

        return lastSyncedAt + minSyncInterval <= Date.now.timeIntervalSince1970
    }

    private(set) var exchangeRates: [ExchangeRate] {
        get {
            let data: Data? = userDefaults.value(forKey: .exchangeRates)

            if let data = data {
                return (try? JSONDecoder().decode([Models.ExchangeRate].self, from: data)) ?? []
            } else {
                return []
            }
        }

        set {
            let exchangeRates = newValue.compactMap { $0 as? Models.ExchangeRate }
            try? userDefaults.setValue(JSONEncoder().encode(exchangeRates), forKey: .exchangeRates)
        }
    }

    @discardableResult
    func get(assets: [String], unitOfAccount: String) async throws -> [ExchangeRate] {
        if getAsyncTask == nil {
            do {
                let result = try await getTask(assets: assets, unitOfAccount: unitOfAccount)
                getAsyncTask = nil
                return result
            } catch let error {
                getAsyncTask = nil
                throw error
            }
        }
        return try await getAsyncTask?.value ?? self.exchangeRates
    }

    func get(asset: String, unitOfAccount: String) async throws -> ExchangeRate? {
        if let exchangeRate = find(by: asset, unitOfAccount: unitOfAccount), !exchangeRate.isExpired, !shouldSync {
            return exchangeRate
        }

        try await get(assets: assetIds(asset: asset), unitOfAccount: unitOfAccount)

        return find(by: asset, unitOfAccount: unitOfAccount)
    }

    func refresh() async throws -> [ExchangeRate] {
        try await get(assets: assetIds(), unitOfAccount: FlexaConstants.usdAssetId)
    }

    private func getTask(assets: [String], unitOfAccount: String) async throws -> [ExchangeRate] {
        getAsyncTask = Task { () -> [ExchangeRate] in
            try await getExchangeRates(assets: assets, unitOfAccount: unitOfAccount)
        }
        return try await getAsyncTask?.value ?? self.exchangeRates
    }

    private func getExchangeRates(assets: [String], unitOfAccount: String) async throws -> [ExchangeRate] {
        let currentExchangeRates = exchangeRates
            .filter { !$0.isExpired }
            .map { $0.asset }

        if !shouldSync && assets.allSatisfy({ currentExchangeRates.contains($0) }) {
            return exchangeRates
        }

        var output = PaginatedOutput<Models.ExchangeRate>()
        var exchangeRates: [Models.ExchangeRate] = []
        let assetIds = assetIds(assets: assets)

        let pagedAssetIds = stride(from: 0, through: assetIds.count, by: maxAssetIds)
            .map { Array(assetIds[$0..<min($0 + maxAssetIds, assetIds.count)]) }

        for assetIds in pagedAssetIds {
            let resource = ExchangeRatesResource.get(
                assets: assetIds,
                unitOfAccount: unitOfAccount,
                limit: nil,
                startingAfter: nil
            )
            output = try await networkClient.sendRequest(
                resource: ExchangeRatesResource.get(
                    assets: assetIds,
                    unitOfAccount: unitOfAccount,
                    limit: nil,
                    startingAfter: nil
                )
            )
            if let data = output.data {
                exchangeRates.append(contentsOf: data)
            }
        }

        self.lastSyncedAt = Date.now.timeIntervalSince1970
        self.exchangeRates = exchangeRates
        return exchangeRates
    }

    func backgroundRefresh() {
        guard shouldBackgroundSync else {
            return
        }
        Task {
            do {
                try await get(assets: assetIdsToRefresh, unitOfAccount: FlexaConstants.usdAssetId)
            } catch let error {
                FlexaLogger.error(error)
            }
        }
    }

    private func assetIds(assets: [String]? = nil, asset: String? = nil) -> [String] {
        let availableAssetIds = assetsRepository.availableClientAssets.map { $0.id }
        var ids = assets?.filter({ availableAssetIds.contains($0) }) ?? availableAssetIds

        if let asset, availableAssetIds.contains(asset) {
            ids.append(asset)
        }

        return Array(Set(ids))
    }

    func find(by asset: String, unitOfAccount: String) -> ExchangeRate? {
        return exchangeRates.first { $0.asset == asset && $0.unitOfAccount == unitOfAccount }
    }
}
