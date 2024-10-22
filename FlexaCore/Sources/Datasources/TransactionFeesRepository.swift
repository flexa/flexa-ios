//
//  TransactionFeesRepository.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

class TransactionFeesRepository: TransactionFeesRepositoryProtocol {
    @Injected(\.flexaNetworkClient) private var networkClient
    @Injected(\.flexaClient) private var flexaClient
    @Injected(\.assetsRepository) private var assetsRepository

    private let maxAssetIds = 20

    @discardableResult
    func get(assets: [String]) async throws -> [Fee] {
        try await getFees(assets: assets)
    }

    func get(asset: String) async throws -> Fee? {
        let fees = try await get(assets: assetIds(asset: asset))
        return fees.first { $0.transactionAsset == asset }
    }

    func refresh() async throws -> [Fee] {
        try await get(assets: assetIds())
    }

    private func getFees(assets: [String]) async throws -> [Fee] {
        var output = PaginatedOutput<Models.Fee>()
        var fees: [Models.Fee] = []
        let assetIds = assetIds(assets: assets)

        let pagedAssetIds = stride(from: 0, through: assetIds.count, by: maxAssetIds)
            .map { Array(assetIds[$0..<min($0 + maxAssetIds, assetIds.count)]) }

        for assetIds in pagedAssetIds {
            output = try await networkClient.sendRequest(
                resource: TransactionFeesResource.get(
                    assets: assetIds,
                    limit: nil,
                    startingAfter: nil
                )
            )
            if let data = output.data {
                fees.append(contentsOf: data)
            }
        }

        return fees
    }

    private func assetIds(assets: [String]? = nil, asset: String? = nil) -> [String] {
        var availableAssets = assetsRepository.availableClientAssets

        if var assets {
            if let asset {
                assets.append(asset)
            }
            availableAssets = availableAssets.filter { availableAsset in
                assets.contains(availableAsset.id)
            }
        }

        let ids = availableAssets
            .map { [$0.id, $0.chain?.nativeAsset].compactMap { $0 } }
            .flatMap { $0 }
            .filter { !$0.isEmpty }

        return Array(Set(ids))
    }
}
