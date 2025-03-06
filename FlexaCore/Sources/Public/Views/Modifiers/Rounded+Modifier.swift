//
//  Rounded+Modifier.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 8/30/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI

public struct RoundedView: ViewModifier {
    var color: Color
    var cornerRadius: CGFloat

    public init(color: Color, cornerRadius: CGFloat = 16) {
        self.color = color
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content
                .background(color)
                .cornerRadius(cornerRadius, corners: .allCorners)
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .circular)
                        .foregroundColor(color)
                )
        }
    }
}
