//
//  AccountView+ViewModel.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 7/30/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

extension AccountView {
    class ViewModel: ObservableObject {
        @Injected(\.accountRepository) private var accountRepository
        @Published var account: Account?
        @Published var error: Error?

        var limits: [Limit] {
            get {
                account?.limits.map { Limit($0) } ?? []
            }
            set {

            }
        }

        var applicationName: String {
            Bundle.applicationDisplayName
        }

        var givenName: String {
            account?.givenName ?? ""
        }

        var familyName: String {
            account?.familyName ?? ""
        }

        var joinedIn: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY"
            return L10n.Account.Header.Labels.joinedIn(
                formatter.string(from: account?.joinedIn ?? Date.now)
            )
        }

        var limitResetsAt: String {
            guard let resetsAt = limits.last?.resetsAt else {
                return ""
            }
            let formatter = DateFormatter()

            formatter.dateFormat = "EEEE"
            let dayOfWeek = formatter.string(from: resetsAt)

            formatter.dateFormat = "h a"
            let time = formatter.string(from: resetsAt)

            return Strings.Sections.Limit.Footer.title(dayOfWeek, time)
        }

        var nameInitials: String {
            [givenName, familyName]
                .compactMap { $0.first }
                .map { String($0).uppercased() }
                .joined()
        }

        var fullName: String {
            account?.fullName ?? ""
        }

        func loadAccount() {
            Task {
                if let account = accountRepository.account {
                    await handleAccountUpdate(account: account)
                }
                do {
                    let account = try await accountRepository.getAccount()
                    await handleAccountUpdate(account: account)
                } catch let error {
                    FlexaLogger.error(error)
                    await handleAccountUpdate(error: error)
                }
            }
        }

        func signOut() {
            FlexaIdentity.disconnect()
        }

        @MainActor
        func handleAccountUpdate(account: Account? = nil, error: Error? = nil) {
            self.account = account
            self.error = error
        }
    }
}

extension AccountView.ViewModel {
    struct Limit: Identifiable {
        let id = UUID()
        let limit: AccountLimit

        var remainingAmount: String {
            limit.description
        }

        var amountPerWeek: String {
            limit.label
        }

        var title: String {
            limit.name
        }

        var remainingPercentage: Double {
            (limit.remaining / limit.amount).doubleValue
        }

        var resetsAt: Date? {
            limit.resetsAt
        }

        init(_ limit: AccountLimit) {
            self.limit = limit
        }

    }
}
