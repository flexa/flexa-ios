//
//  ExchangeRatesRepositoryProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 9/27/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

public protocol ExchangeRatesRepositoryProtocol {
    var exchangeRates: [ExchangeRate] { get }
    var shouldSync: Bool { get }

    @discardableResult
    func refresh() async throws -> [ExchangeRate]
    func backgroundRefresh()
    func find(by asset: String, unitOfAccount: String) -> ExchangeRate?
    func get(asset: String, unitOfAccount: String) async throws -> ExchangeRate?
    func get(assets: [String], unitOfAccount: String) async throws -> [ExchangeRate]
}
