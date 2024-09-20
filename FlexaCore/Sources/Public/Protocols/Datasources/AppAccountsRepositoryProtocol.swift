//
//  AppAccountsRepository.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 3/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

public protocol AppAccountsRepositoryProtocol {
    var appAccounts: [AppAccount] { get }
    var syncDateOffset: TimeInterval? { get }

    @discardableResult
    func refresh() async throws -> [AppAccount]
    func backgroundRefresh()
    func sanitizeSelectedAsset()
}
