//
//  AssetConverterRepositoryProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/11/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

public protocol AssetConverterRepositoryProtocol {
    func convert(amount: Decimal, from: String, to: String) async throws -> ConvertedAsset
}
