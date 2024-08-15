//
//  SpendModalHeader.swift
//  FlexaUICore
//
//  Created by Rodrigo Ordeix on 8/30/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import Foundation
import SwiftUI
import FlexaCore

public struct SpendModalHeader: View {
    var title: String
    private var titleColor: Color
    private var grabberColor: Color
    private var closeButtonColor: Color
    var closeButton: Bool
    var enableGrabber: Bool
    var image: Image?
    var closeAction: (() -> Void)?

    public init(title: String = "",
                titleColor: Color = .primary,
                grabberColor: Color = .primary.opacity(0.2),
                closeButtonColor: Color = .primary.opacity(0.2),
                closeButton: Bool = false,
                enableGrabber: Bool = false,
                image: Image? = nil,
                closeAction: (() -> Void)? = nil) {
        self.title = title
        self.titleColor = titleColor
        self.grabberColor = grabberColor
        self.closeButtonColor = closeButtonColor
        self.closeButton = closeButton
        self.image = image
        self.closeAction = closeAction
        self.enableGrabber = enableGrabber
    }

    public var body: some View {
        ZStack {
            if enableGrabber {
                Capsule().fill(grabberColor)
                    .frame(width: 57, height: 6).padding(.top, -14)
            }
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.body.weight(.semibold))
                .foregroundColor(titleColor).padding(.top, 20)
                HStack {
                    if let image = image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 22, alignment: .center)
                    }
                    Spacer()
                    if closeButton {
                        ZStack {
                            FlexaRoundedButton(.close, buttonAction: closeAction)
                        }
                    }
                }.padding(.top, 24)
                .padding(.horizontal, 16)
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(Color(.clear))
    }
}
