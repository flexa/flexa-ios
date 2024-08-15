//
//  DeleteAccountView+ViewModel.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 2/8/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

extension DeleteAccountView {
    class ViewModel: ObservableObject {
        @Injected(\.accountRepository) var accountsRepository

        @Published var isLoading = false
        @Published var error: Error?
        @Published var shouldGoVerifyEmail: Bool = false

        func deleteAccount() {
            isLoading = true
            Task {
                do {
                    _ = try await accountsRepository.deleteAccount()
                    await handleDeletion()
                } catch let error {
                    await handleDeletion(error)
                }
            }
        }

        @MainActor
        private func handleDeletion(_ error: Error? = nil) {
            isLoading = false
            self.error = error
            shouldGoVerifyEmail = error == nil
        }
    }
}
