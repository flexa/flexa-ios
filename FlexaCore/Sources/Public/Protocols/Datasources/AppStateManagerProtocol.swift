//
//  TransactionsRepositoryProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/11/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol AppStateManagerProtocol {
    func refresh()
    func signTransaction(commerceSessionId: String, signature: String)
    func addTransaction(commerceSessionId: String, transactionId: String)
}
