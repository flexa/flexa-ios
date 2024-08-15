//
//  AssetConverterRepository.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/12/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

class AssetConverterRepository: AssetConverterRepositoryProtocol {
    @Injected(\.flexaNetworkClient) private var networkClient

    func convert(amount: Decimal, from: String, to: String) async throws -> ConvertedAsset {
        let exchangeRate: Models.ConvertedAsset = try await networkClient.sendRequest(
            resource: AssetConverterResource.convert(
                ConvertAssetInput(
                    amount: amount,
                    asset: from,
                    unitOfAccount: to
                )
            )
        )
        return exchangeRate
    }
}
