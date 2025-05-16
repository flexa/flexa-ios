//
//  MagicCodeView+ViewModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory
import UIKit

extension MagicCodeView {
    class ViewModel: ObservableObject {
        @Injected(\.authStore) var authStore
        @Injected(\.appStateManager) var appStateManager

        @Published var isLoading: Bool = false
        @Published var validated: Bool = false
        @Published var error: Error?
        @Published var code: String = "" {
            didSet {
                validateWithCode()
            }
        }

        func endEditing() {
            UIApplication.shared.connectedScenes
                .compactMap({ $0.activationState == .foregroundActive ? $0 as? UIWindowScene : nil })
                .first?
                .windows
                .first?
                .endEditing(true)
        }

        func validateWithUrl(_ url: URL?) -> Bool {
            guard case .verify = url?.flexaLink else {
                return false
            }

            validate(url: url)
            return true
        }

        private func validateWithCode() {
            guard !code.isEmpty else {
                return
            }

            validate(code: code)
        }

        private func validate(code: String? = nil, url: URL? = nil) {
            if url == nil && (code == nil || code?.isEmpty == true) {
                return
            }

            isLoading = true
            validated = false

            Task { [self] in
                do {
                    let result = try await authStore.verify(code: code, link: url?.absoluteString)
                    await appStateManager.refresh()
                    await handleState(result)
                } catch let error {
                    await handleState(error: error)
                }
            }
        }

        @MainActor
        private func handleState(_ state: AuthStoreState = .none, error: Error? = nil) async {
            self.validated = state == .loggedIn
            self.isLoading = self.validated
            self.error = error
        }
    }
}
