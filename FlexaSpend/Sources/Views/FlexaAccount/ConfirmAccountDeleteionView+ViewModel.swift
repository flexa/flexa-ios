//
//  ConfirmAccountDeletionView+ViewModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/6/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import UIKit
import Factory

extension ConfirmAccountDeletionView {
    class ViewModel: ObservableObject {
        @Injected(\.accountRepository) var accountsRepository

        var emailAddress: String {
            accountsRepository.account?.emailAddress ?? ""
        }

        func openMail() {
            if let url = URL(string: "message://"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                FlexaLogger.error("Cannot open mail app")
            }
        }
    }
}
