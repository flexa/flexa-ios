//
//  DataAndPrivacyView.swift
//  SwiftUIPlayground
//
//  Created by Rodrigo Ordeix on 7/30/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

extension DataAndPrivacyView {
    class ViewModel: ObservableObject {
        @Injected(\.accountRepository) var accountsRepository

        var account: Account? {
            accountsRepository.account
        }

        var email: String {
            account?.emailAddress ?? ""
        }

        var sdkVersion: String {
            Flexa.version
        }

        var isPendingDeletion: Bool {
            account?.status == .pendingDeletion
        }
    }
}
