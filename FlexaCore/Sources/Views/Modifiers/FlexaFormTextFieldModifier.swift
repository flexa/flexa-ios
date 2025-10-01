//
//  FlexaFormTextFieldnModifier.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/3/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

extension View {
    func flexaFormTextField(cornerRadius: CGFloat = 10,
                            backgroundColor: Color = .secondary.opacity(0.2)
    ) -> some View {
        modifier(FlexaFormTextFieldModifier(cornerRadius: cornerRadius, backgroundColor: backgroundColor))
    }
}

struct FlexaFormTextFieldModifier: ViewModifier {
    var cornerRadius: CGFloat
    var backgroundColor: Color

    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            commonProperties(content)
                .clipShape(.capsule)
        } else {
            commonProperties(content)
                .cornerRadius(cornerRadius)
        }

    }

    private func commonProperties(_ content: Content) -> some View {
        content
            .font(.body)
            .foregroundColor(.primary)
            .padding()
            .background(backgroundColor)
    }
}
