//
//  FlexaMainButtonModifier.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/3/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

public extension View {

    private func getTextColor(for backgroundColor: Color?) -> Color {
        guard let backgroundColor, !backgroundColor.isDark else {
            return .white
        }
        return .black
    }

    func flexaButton(
        background: some View = Color.flexaTintColor,
        textColor: Color? = nil,
        disabledTextColor: Color? = nil,
        cornerRadius: CGFloat = 10,
        disabledOpacity: CGFloat = 0.2) -> some View {
            modifier(
                FlexaMainButtonModifier(
                    color: background,
                    textColor: textColor ?? getTextColor(for: background as? Color),
                    disabledTextColor: disabledTextColor ?? textColor ?? getTextColor(for: background as? Color),
                    cornerRadius: cornerRadius,
                    disabledOpacity: disabledOpacity
                )
            )
        }
}

struct FlexaMainButtonModifier: ViewModifier {
    var color: any View
    var textColor: Color
    var disabledTextColor: Color
    var cornerRadius: CGFloat
    var disabledOpacity: CGFloat

    @Environment(\.isEnabled) var isEnabled

    func body(content: Content) -> some View {
        content
            .font(.body.weight(.semibold))
            .foregroundColor(isEnabled ? textColor : disabledTextColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AnyView(color).opacity(isEnabled ? 1 : disabledOpacity))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
