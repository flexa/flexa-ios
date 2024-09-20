//
//  AccountsRepository.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/15/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

class AccountsRepository: AccountsRepositoryProtocol {
    @Injected(\.flexaNetworkClient) var networkClient
    @Injected(\.keychainHelper) var keychainHelper
    @Injected(\.authStore) var authStore

    var account: Account? {
        modelAccount
    }

    private var modelAccount: Models.Account? {
        get {
            var account: Models.Account? = keychainHelper.value(forKey: .flexaAccount)
            account?.emailAddress = authStore.email ?? ""
            return account
        }
        set {
            keychainHelper.setValue(newValue, forKey: .flexaAccount)
        }
    }

    func create(email: String,
                givenName: String,
                familyName: String,
                dateOfBirth: Date,
                countryCode: String) async throws -> EmptyAccount {
        try await networkClient.sendRequest(
            resource: AccountsResource.create(
                CreateAccountInput(
                    email: email,
                    givenName: givenName,
                    familyName: familyName,
                    dateOfBirth: dateOfBirth,
                    countryCode: countryCode
                )
            )
        ) as Models.EmptyAccount
    }

    @discardableResult
    func getAccount() async throws -> Account {
        let account = try await networkClient.sendRequest(resource: AccountsResource.get) as Models.Account
        modelAccount = account
        return account
    }

    func refresh() async throws {
        await try getAccount()
    }

    func backgroundRefresh() {
        Task {
            do {
                try await getAccount()
            } catch let error {
                FlexaLogger.error(error)
            }
        }
    }

    func deleteAccount() async throws -> Account {
        let account = try await networkClient.sendRequest(resource: AccountsResource.delete) as Models.Account
        modelAccount = account
        return account
    }
}
