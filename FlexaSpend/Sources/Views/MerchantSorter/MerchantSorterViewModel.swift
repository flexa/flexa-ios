//
//  MerchantSorterViewModel.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 9/26/23.
//  Copyright © 2023 Flexa. All rights reserved.
//
import Foundation
import Factory

extension MerchantSorter {
    class ViewModel: ObservableObject {
        @Injected(\.brandsRepository) var brandsRepository

        @Published private(set) var pinnedBrands: [Brand] = []

        var otherBrands: [Brand] {
            brands.filter { brand in
                !pinnedBrands.contains(where: { brand.id == $0 .id })
            }
        }

        private var brands: [Brand] = []

        required init() {
            DispatchQueue.main.async { [self] in
                brands = brandsRepository.legacyFlexcodeBrands

                self.pinnedBrands = brandsRepository.pinnedBrandIds.compactMap { brandId in
                    brands.first { $0.id == brandId }
                }
            }
        }

        func pinBrand(_ brand: Brand) {
            guard !pinnedBrands.contains(where: { $0.id == brand.id }) else {
                return
            }
            pinnedBrands.append(brand)
            brandsRepository.pinBrand(brand)
        }

        func unpinBrand(_ brand: Brand) {
            pinnedBrands.removeAll { $0.id == brand.id }
            brandsRepository.unpinBrand(brand)
        }

        func togglePinState(brand: Brand, pinned: Bool) {
            if pinned {
                unpinBrand(brand)
            } else {
                pinBrand(brand)
            }
        }

        func movePinnedBrand(from source: IndexSet, to destination: Int) {
            pinnedBrands.move(fromOffsets: source, toOffset: destination)
            brandsRepository.movePinnedBrand(from: source, to: destination)
        }
    }
}
