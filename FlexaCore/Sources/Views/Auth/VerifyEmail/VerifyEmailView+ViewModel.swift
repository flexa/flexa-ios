//
//  VerifyEmailView+ViewModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/6/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import UIKit
import Factory

extension VerifyEmailView {
    class ViewModel: ObservableObject {
        var emailAddress: String
        var headerTitle: String
        var headerSubtitle: String
        var bottomTitle: String

        init(emailAddress: String, registering: Bool = false) {
            self.emailAddress = emailAddress
            if registering {
                headerTitle = Strings.Header.SignUp.title
                headerSubtitle = Strings.Header.SignUp.subtitle
                bottomTitle = Strings.Table.Rows.SignUp.title
            } else {
                headerTitle = Strings.Header.SignIn.title
                headerSubtitle = Strings.Header.SignIn.subtitle
                bottomTitle = Strings.Table.Rows.SignIn.title
            }
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
