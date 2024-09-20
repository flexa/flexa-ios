//
//  PersonalInformationView+ViewModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/1/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import Factory

extension PersonalInformationView {
    class ViewModel: ObservableObject {
        static var defaultDate: Date {
            DateComponents(
                calendar: .current,
                year: Calendar.current.component(.year, from: Date.now) - 18
            ).date ?? Date()
        }

        @Injected(\.accountRepository) var accountRepository
        @Injected(\.authStore) var authStore
        @Published var givenName: String = ""
        @Published var familyName: String = ""
        @Published var isLoading: Bool = false
        @Published var error: Error?
        @Published var shouldGoVerifyEmail: Bool = false
        @Published var dateOfBirth: Date = defaultDate {
            didSet {
                birthDateFormatted = dateOfBirth.formatted(date: .abbreviated, time: .omitted)
            }
        }

        var fullName: String {
            "\(givenName) \(familyName)".trimmingCharacters(in: .whitespacesAndNewlines)
        }

        var birthDateText: String {
            birthDateFormatted.isEmpty ? Strings.Textfields.DateOfBirth.placeholder : birthDateFormatted
        }

        var birthDateForegroundColor: Color {
            birthDateFormatted.isEmpty ? Color(UIColor.placeholderText) : .primary
        }

        var isValid: Bool {
            !givenName.isEmpty && !familyName.isEmpty && !birthDateFormatted.isEmpty
        }

        var applicationName: String {
            Bundle.applicationDisplayName
        }

        var emailAddress: String

        private var birthDateFormatted: String = ""
        private var countryCode: String {
            if #available(iOS 16, *) {
                return Locale.current.region?.identifier ?? "US"
            } else {
                return Locale.current.regionCode ?? "US"
            }
        }

        init(emailAddress: String) {
            self.emailAddress = emailAddress
        }

        func createAccount() {
            isLoading = true

            Task {
                do {
                    try await accountRepository.create(
                        email: emailAddress,
                        givenName: givenName,
                        familyName: familyName,
                        dateOfBirth: dateOfBirth,
                        countryCode: countryCode
                    )

                    let result = try await authStore.signIn(with: emailAddress)
                    await MainActor.run {
                        self.isLoading = false
                        self.shouldGoVerifyEmail = result == .verifying || result == .loggedIn
                    }
                } catch let error {
                    FlexaLogger.error(error)
                    await MainActor.run {
                        self.isLoading = false
                        self.error = error
                    }
                }
            }
        }
    }
}
