//
//  OneTimeKeysRepository.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/2/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

class OneTimeKeysRepository: OneTimeKeysRepositoryProtocol {
    @Injected(\.flexaNetworkClient) private var networkClient
    @Injected(\.flexaClient) private var flexaClient
    @Injected(\.assetsRepository) private var assetsRepository
    @Injected(\.assetConfig) private var assetConfig
    @Injected(\.keychainHelper) private var keychainHelper
    @Injected(\.eventNotifier) private var eventNotifier

    var keys: [String: OneTimeKey] {
        storedKeys
    }

    var syncDateOffset: TimeInterval? {
        didSet {
            keychainHelper.setValue(syncDateOffset, forKey: .lastOneTimeKeysSyncOffset)
        }
    }

    @Synchronized private var storedKeys: [String: Models.OneTimeKey] = [:] {
        didSet {
            keychainHelper.setValue(storedKeys.map { $0.value }, forKey: .oneTimeKeys)
            eventNotifier.post(name: .oneTimeKeysDidUpdate)
        }
    }

    init() {
        let savedKeys: [Models.OneTimeKey] = keychainHelper.value(forKey: .oneTimeKeys) ?? []
        storedKeys = savedKeys.reduce(into: [String: Models.OneTimeKey]()) { $0[$1.id] = $1 }
        syncDateOffset = keychainHelper.value(forKey: .lastOneTimeKeysSyncOffset)
    }

    @discardableResult
    func refresh() async throws -> [String: OneTimeKey] {
        var output: PaginatedOutput<Models.OneTimeKey>?
        var response: HTTPURLResponse?
        var error: Error?
        let asssets = assetsRepository.availableClientAssets.map { $0.id }

        (output, response, error) = await networkClient.sendRequest(
            resource: OneTimeKeysResource.sync(
                SyncOneTimeKeysInput(assets: asssets)
            )
        )

        if let error {
            purgeExpired()
            throw error
        }

        guard let response, let output else {
            purgeExpired()
            return storedKeys
        }

        syncDateOffset = Date().timeIntervalSince1970 - (response.responseDate?.timeIntervalSince1970 ?? 0)
        let syncedKeys = output.data?.reduce(into: [String: Models.OneTimeKey]()) { $0[$1.id] = $1 } ?? [:]
        storedKeys = storedKeys.merging(syncedKeys) { $1 }
        purgeExpired()
        flexaClient.sanitizeSelectedAsset()
        return storedKeys
    }

    func backgroundRefresh() {
        Task {
            do {
                try await refresh()
            } catch let error {
                FlexaLogger.error(error)
            }
        }
    }

    func purgeExpired() {
        storedKeys = storedKeys.filter { !$0.value.isExpired }
        if storedKeys.isEmpty {
            syncDateOffset = nil
        }
    }

    func purgeAll() {
        storedKeys = [:]
        syncDateOffset = nil
    }
}
