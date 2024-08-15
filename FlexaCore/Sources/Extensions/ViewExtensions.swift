//
//  ViewExtensions.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 8/5/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

// Flexa Privacy
extension View {
    func flexaPrivacyAlert(isPresented: Binding<Bool>) -> some View {
        alert(isPresented: isPresented) {
            Alert(
                title: Text(CoreStrings.Auth.Privacy.Alerts.About.title),
                message: Text(CoreStrings.Auth.Privacy.Alerts.About.message(Bundle.applicationDisplayName)),
                dismissButton: .cancel(
                    Text(CoreStrings.Global.ok)
                )
            )
        }
    }
}

// Alerts
extension View {
    func blankView() -> some View {
        Text("")
            .frame(width: 0, height: 0)
            .hidden()
            .alertTintColor(.purple)
    }
}
