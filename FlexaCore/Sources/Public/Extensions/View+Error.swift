//
//  View+Error.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 3/15/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI
import Foundation
import FlexaNetworking
import Factory

public extension View {
    @ViewBuilder
    func onError(error: Binding<Error?>, buttonTitle: String? = nil) -> some View {
        if let networkError = error.wrappedValue as? FlexaNetworking.NetworkError,
           networkError.isUnauthorized,
           case NetworkError.invalidStatus(_, let resource, _) = networkError,
           resource is JWTAuthenticable {
            self.task {
                Container.shared.flexaNotificationCenter().post(name: .flexaAuthorizationError, object: nil)
            }
        } else {
            self.errorAlert(error: error, buttonTitle: buttonTitle)
        }
    }

    func errorAlert(error: Binding<Error?>, buttonTitle: String? = nil) -> some View {
        var reasonableError = error.wrappedValue as? ReasonableError

        if let wrappedError = error.wrappedValue, reasonableError == nil {
            reasonableError = ReasonableError.custom(error: wrappedError)
        }

        return alert(isPresented: .constant(reasonableError != nil)) {
            Alert(
                title: Text(reasonableError?.title ?? ""),
                message: Text(reasonableError?.recoverySuggestion ?? ""),
                dismissButton: .default(Text(buttonTitle ?? CoreStrings.Global.ok), action: {
                    error.wrappedValue = nil
                })
            )
        }
    }
}
