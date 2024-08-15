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

    func refresh() async throws -> [Brand] {
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

        all = brands
        return brands
    }

    func refreshLegacyFlexcodeBrands() async throws -> [Brand] {
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

        legacyFlexcodeBrands = brands
        return brands
    }

    func backgroundRefresh() {
        Task {
            do {
                let brands = try await refresh()
                imageLoader.loadImages(fromUrls: brands.compactMap { $0.logoUrl })
            } catch let error {
                FlexaLogger.error(error)
            }

            do {
                _ = try await refreshLegacyFlexcodeBrands()
            } catch let error {
                FlexaLogger.error(error)
            }
        }
    }
}
