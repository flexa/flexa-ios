//
//  LegacyFlexcodeTray.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 10/2/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import Foundation
import Factory

extension LegacyFlexcodeList {
    class ViewModel: ObservableObject {
        @Injected(\.brandsRepository) var brandsRepository: BrandsRepositoryProtocol
        @Published var brands: [Brand] = []

        init() {
            refreshMerchants()
            Task { [weak self] in
                _ = try await self?.brandsRepository.refresh()
                self?.refreshMerchants()
            }
        }

        func refreshMerchants() {
            DispatchQueue.main.async {
                let pinnedMerchantIds = self.brandsRepository.pinnedBrandIds
                self.brands = pinnedMerchantIds.compactMap { brandId in
                    self.brandsRepository.legacyFlexcodeBrands.first { $0.id == brandId }
                } + self.brandsRepository.legacyFlexcodeBrands.filter { !pinnedMerchantIds.contains($0.id) }
            }
        }
    }
}
