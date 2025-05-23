//
//  TransactionsRepositoryProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/11/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol AppStateManagerProtocol {
    var closeCommerceSessionOnDismissal: Bool { get set }
    func resetState()
    func backgroundRefresh()
    func refresh() async
    func purgeIfNeeded()
    func closeCommerceSession(commerceSessionId: String)
    func signTransaction(commerceSessionId: String, signature: String)
    func addTransaction(commerceSessionId: String, transactionId: String)
}
