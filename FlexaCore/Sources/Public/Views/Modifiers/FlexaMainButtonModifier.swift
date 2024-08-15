//
//  FlexaMainButtonModifier.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/3/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

public extension View {
    func flexaButton(
        background: some View = Color.purple,
        textColor: Color = .white,
        disabledTextColor: Color? = nil,
        cornerRadius: CGFloat = 10) -> some View {
            modifier(
                FlexaMainButtonModifier(
                    color: background,
                    textColor: textColor,
                    disabledTextColor: disabledTextColor ?? textColor,
                    cornerRadius: cornerRadius
                )
            )
        }
}

struct FlexaMainButtonModifier: ViewModifier {
    var color: any View
    var textColor: Color
    var disabledTextColor: Color
    var cornerRadius: CGFloat

    @Environment(\.isEnabled) var isEnabled

    func body(content: Content) -> some View {
        content
            .font(.body.weight(.semibold))
            .foregroundColor(isEnabled ? textColor : disabledTextColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AnyView(color).opacity(isEnabled ? 1 : 0.2))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
