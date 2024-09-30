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

    private let maxAssetIds = 20

    private var assetIdsToRefresh: [String] {
        assetIds()
    }

    var isExpired: Bool {
        Date().timeIntervalSince1970 >= expireAt
    }

    var expireAt: Double {
        Double(
            exchangeRates
                .map { $0.expiresAt }
                .min() ?? 0
        )
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
        var output = PaginatedOutput<Models.ExchangeRate>()
        var exchangeRates: [Models.ExchangeRate] = []
        let assetIds = assetIds(assets: assets)

        let pagedAssetIds = stride(from: 0, through: assetIds.count, by: maxAssetIds)
            .map { Array(assetIds[$0..<min($0 + maxAssetIds, assetIds.count)]) }

        for assetIds in pagedAssetIds {
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

        self.exchangeRates = exchangeRates
        return exchangeRates
    }

    func get(asset: String, unitOfAccount: String) async throws -> ExchangeRate? {
        if let exchangeRate = find(by: asset, unitOfAccount: unitOfAccount), !exchangeRate.isExpired {
            return exchangeRate
        }

        try await get(assets: assetIds(asset: asset), unitOfAccount: unitOfAccount)

        return find(by: asset, unitOfAccount: unitOfAccount)
    }

    func refresh() async throws -> [ExchangeRate] {
        try await get(assets: assetIds(), unitOfAccount: FlexaConstants.usdAssetId)
    }

    func backgroundRefresh() {
        Task {
            do {
                try await get(assets: assetIdsToRefresh, unitOfAccount: FlexaConstants.usdAssetId)
            } catch let error {
                FlexaLogger.error(error)
            }
        }
    }

    private func assetIds(assets: [String]? = nil, asset: String? = nil) -> [String] {
        var ids = assets ?? flexaClient.appAccounts
            .flatMap { $0.availableAssets }
            .map { $0.assetId }

        if let asset {
            ids.append(asset)
        }

        return Array(Set(ids))
    }

    func find(by asset: String, unitOfAccount: String) -> ExchangeRate? {
        return exchangeRates.first { $0.asset == asset && $0.unitOfAccount == unitOfAccount }
    }
}
