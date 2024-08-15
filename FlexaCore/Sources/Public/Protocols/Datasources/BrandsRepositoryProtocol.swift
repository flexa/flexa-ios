//
//  BrandsRepositoryProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 3/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol BrandsRepositoryProtocol {
    var all: [Brand] { get }
    var legacyFlexcodeBrands: [Brand] { get }
    var pinnedBrandIds: [String] { get }

    func refresh() async throws -> [Brand]
    func backgroundRefresh()
    func pinBrand(_: Brand)
    func unpinBrand(_: Brand)
    func movePinnedBrand(from source: IndexSet, to destination: Int)
}
