//
//  TransactionFeesRepositoryProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

public protocol TransactionFeesRepositoryProtocol {
    func get(asset: String) async throws -> Fee?
}
