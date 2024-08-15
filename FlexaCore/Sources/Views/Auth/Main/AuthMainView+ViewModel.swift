//
//  AuthMainView+ViewModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/3/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import UIKit
import Factory

extension AuthMainView {
    class ViewModel: ObservableObject {
        @Injected(\.authStore) var authStore

        @Published var error: Error?
        @Published var isLoading: Bool = false
        @Published var emailAddress: String = ""
        @Published var shouldGoVerifyEmail: Bool = false
        @Published var shouldGoPersonalInfo: Bool = false

        var applicationName: String {
            Bundle.applicationDisplayName
        }

        var isValid: Bool {
            emailAddress.isEmail
        }

        var isContinueButtonEnabled: Bool {
            isValid && !isLoading
        }

        func verifyEmailAddress() {
            guard isValid, !isLoading else {
                return
            }

            isLoading = true
            shouldGoVerifyEmail = false
            shouldGoPersonalInfo = false

            Task { [self] in
                do {
                    let result = try await authStore.signIn(with: emailAddress)
                    await MainActor.run {
                        self.isLoading = false
                        self.shouldGoVerifyEmail = result == .verifying || result == .loggedIn
                    }
                } catch let error {
                    await MainActor.run {
                        self.isLoading = false
                        self.shouldGoPersonalInfo = true
                    }
                }

            }
        }
    }
}
