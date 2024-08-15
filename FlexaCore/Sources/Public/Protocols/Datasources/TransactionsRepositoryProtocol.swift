//
//  AppStateManagerProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/11/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol TransactionsRepositoryProtocol {
    func addSignature(transactionId: String, signature: String) async throws
}
