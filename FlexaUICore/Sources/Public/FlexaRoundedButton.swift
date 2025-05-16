//
//  FlexaRoundedButton.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/3/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

public extension FlexaRoundedButton {
    enum ButtonType {
        case close
        case settings
        case info
        case custom(_ image: Image)
    }
}

public struct FlexaRoundedButton: View {
    var buttonAction: (() -> Void)?
    var color: Color
    var backgroundColor: Color
    var buttonType: ButtonType
    var symbolFont: Font
    var size: CGSize

    var image: Image {
        switch buttonType {
        case .close:
            return Image(systemName: "xmark")
        case .settings:
            return Image(systemName: "ellipsis")
        case .info:
            return Image(systemName: "info")
        case .custom(let image):
            return image

        }
    }

    public init(_ buttonType: ButtonType,
                color: Color = .secondary,
                backgroundColor: Color = Color(UIColor.tertiarySystemFill.withAlphaComponent(0.16)),
                symbolFont: Font = Font.system(size: 15, weight: .semibold, design: .rounded),
                size: CGSize = CGSize(width: 30, height: 30),
                buttonAction: (() -> Void)? = nil) {
        self.buttonType = buttonType
        self.color = color
        self.backgroundColor = backgroundColor
        self.symbolFont = symbolFont
        self.size = size
        self.buttonAction = buttonAction
    }

    public var body: some View {
        if buttonAction != nil {
            button
        } else {
            label
        }
    }

    private var label: some View {
        ZStack(alignment: .center) {
            Circle()
                .fill(backgroundColor)
                .frame(width: size.width, height: size.height, alignment: .center)
            image
                .imageScale(.medium)
                .font(symbolFont)
                .foregroundColor(color)
        }
    }

    private var button: some View {
        Button {
            buttonAction?()
        } label: {
            label
        }.buttonStyle(PlainButtonStyle())
    }
}
