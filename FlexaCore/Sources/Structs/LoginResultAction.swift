//
//  LoginResultAction.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/29/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

struct LoginResultAction {
    typealias Action = ((ConnectResult) -> Void)?
    let action: Action

    init(_ action: Action) {
        self.action = action
    }

    func callAsFunction(_ result: ConnectResult) {
        action?(result)
    }
}

struct LoginResultKey: EnvironmentKey {
    static let defaultValue: LoginResultAction? = nil
}

extension EnvironmentValues {
    var loginResult: LoginResultAction? {
        get { self[LoginResultKey.self] }
        set { self[LoginResultKey.self] = newValue }
    }
}

extension View {
    func onLoginResult(_ action: LoginResultAction.Action) -> some View {
        self.environment(\.loginResult, LoginResultAction(action))
    }
}
