//
//  SpendButton.swift
//  FlexaUICore
//
//  Created by Marcelo Korjenoski on 10/11/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import SwiftUI

public extension SpendButton {
    struct Theme {
        public let buttonFill: Color
        public let buttonText: Color
        public let buttonDisabledFill: Color
        public let buttonDisabledText: Color

        public init(buttonFill: Color, buttonText: Color, buttonDisabledFill: Color, buttonDisabledText: Color) {
            self.buttonFill = buttonFill
            self.buttonText = buttonText
            self.buttonDisabledFill = buttonDisabledFill
            self.buttonDisabledText = buttonDisabledText
        }
    }
}

public struct SpendButton: View {
    var title: String
    var buttonAction: () -> Void
    var theme: Theme

    public init(_ title: String, buttonAction: @escaping () -> Void, theme: Theme) {
        self.title = title
        self.buttonAction = buttonAction
        self.theme = theme
    }

    public var body: some View {
        Button {
            buttonAction()
        } label: {
            Text(title)
                .frame(minWidth: 0, maxWidth: .infinity)
                .font(.body.weight(.semibold))
                .padding()
                .foregroundColor(theme.buttonText)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(theme.buttonFill, lineWidth: 0)
                )
        }
        .background(theme.buttonFill)
        .cornerRadius(16)
    }
}

struct SpendButton_Previews: PreviewProvider {
    static var previews: some View {
        let theme = SpendButton.Theme(buttonFill: .black,
                                    buttonText: .white,
                                    buttonDisabledFill: .gray,
                                    buttonDisabledText: .white)
        SpendButton("Button 1", buttonAction: {}, theme: theme)
    }
}
