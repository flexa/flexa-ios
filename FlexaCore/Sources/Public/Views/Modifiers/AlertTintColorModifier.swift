//
//  AlertTintColorModifier.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/6/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

public struct AlertTintColorModifier: ViewModifier {
    let tintColor: Color
    private static var uiView = UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
    private var previousTintColor = Self.uiView.tintColor

    public init(_ tintColor: Color) {
        self.tintColor = tintColor
    }

    public func body(content: Content) -> some View {
        content.onAppear {
            Self.uiView.tintColor = UIColor(tintColor)
        }.onDisappear {
            Self.uiView.tintColor = previousTintColor
        }
    }
}

public extension View {
    func alertTintColor(_ color: Color) -> some View {
        modifier(AlertTintColorModifier(color))
    }
}
