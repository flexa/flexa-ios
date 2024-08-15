//
//  SpendMessageView.swift
//  FlexaSpend
//
//  Created by Marcelo Korjenioski on 12/15/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore

struct SpendMessageView: View {
    @Environment(\.theme.containers.notifications) var theme

    var title: String
    var description: String
    var buttonTitle: String
    var closeAction: () -> Void
    var buttonAction: () -> Void

    let gradientStops: [Gradient.Stop] = [
        Gradient.Stop(color: Color(UIColor(red: 205.0 / 255.0, green: 88.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)), location: 0),
        Gradient.Stop(color: Color(UIColor(red: 28.0 / 255.0, green: 19.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)), location: 0.31),
        Gradient.Stop(color: Color(UIColor(red: 24.0 / 255.0, green: 109.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)), location: 0.5),
        Gradient.Stop(color: Color(UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)), location: 0.5),
        Gradient.Stop(color: Color(UIColor(red: 251.0 / 255.0, green: 235.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)), location: 0.62),
        Gradient.Stop(color: Color(UIColor(red: 250.0 / 255.0, green: 128.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)), location: 0.91)
    ]

    init(_ title: String,
         _ description: String,
         _ buttonTitle: String,
         closeAction: @escaping () -> Void,
         buttonAction: @escaping () -> Void) {
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.closeAction = closeAction
        self.buttonAction = buttonAction
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                closeAction()
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Asset.messageCloseButton)
                    .frame(width: 14, height: 14, alignment: .center)
                    .padding(4)
            }.padding([.trailing, .top], 16)
            HStack(alignment: .top, spacing: 12) {
                AngularGradient(stops: gradientStops, center: .center)
                    .mask(
                        RoundedRectangle(cornerRadius: 6)
                    )
                    .frame(width: 36, height: 36)
                    .padding([.leading, .top], 16)
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .multilineTextAlignment(.leading)
                        .font(.body.weight(.semibold))
                        .foregroundColor(Color(UIColor.label))
                        .padding(.top, 16)
                        .padding(.trailing, 30)
                    Text(description)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline.weight(.light))
                        .foregroundColor(Asset.messageDescriptionText)
                        .padding([.trailing, .bottom], 15)
                    Divider().background(Asset.messageSeparator.swiftUIColor)
                    Button {
                        buttonAction()
                    } label: {
                        Text(buttonTitle)
                            .multilineTextAlignment(.leading)
                            .font(.body.weight(.regular))
                            .foregroundColor(Asset.commonLink)
                            .padding([.trailing, .bottom], 16)
                    }
                }.padding(0)
            }
        }
        .frame(maxWidth: .infinity)
        .modifier(RoundedView(color: backgroundColor, cornerRadius: cornerRadius))
    }
}

struct SpendMessageView_Previews: PreviewProvider {
    static var previews: some View {
        SpendMessageView("title", "description", "button", closeAction: {}, buttonAction: {})
    }
}

// MARK: Theming
private extension SpendMessageView {
    var cornerRadius: CGFloat {
        theme.borderRadius
    }

    var backgroundColor: Color {
        theme.backgroundColor
    }
}
