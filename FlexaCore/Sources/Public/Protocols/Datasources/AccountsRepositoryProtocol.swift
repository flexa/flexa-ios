//
//  AccountsRepositoryProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/31/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

public protocol AccountsRepositoryProtocol {
    var account: Account? { get }

    @discardableResult
    func create(email: String,
                givenName: String,
                familyName: String,
                dateOfBirth: Date,
                countryCode: String
    ) async throws -> EmptyAccount

    func getAccount() async throws -> Account
    func refresh() async throws
    func backgroundRefresh()

    @discardableResult
    func deleteAccount() async throws -> Account
}
