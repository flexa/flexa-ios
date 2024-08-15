//
//  DragIndicatorModifier.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 9/27/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI

public struct DragIndicatorModifier: ViewModifier {
    public let show: Bool
    public let fillColor: Color

    public func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            content.presentationDragIndicator(show ? .visible : .hidden)
        } else {
            if show {
                ZStack(alignment: .top) {
                    content
                    Capsule()
                        .fill(fillColor)
                        .frame(width: 36, height: 5)
                        .padding(10)
                }
            } else {
                content
            }
        }
    }
}

public extension View {
    func dragIndicator(_ show: Bool, backgroundColor: Color = Color(UIColor.systemGray4)) -> some View {
        self.modifier(DragIndicatorModifier(show: show, fillColor: backgroundColor))
    }
}
