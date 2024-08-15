//
//  SheetCornerRadiusModifier.swift
//  FlexaUICore
//
//  Created by Rodrigo Ordeix on 2/5/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI
import SwiftUIIntrospect

public struct SheetCornerRadiusModifier: ViewModifier {
    private var cornerRadius: CGFloat?

    public init(_ cornerRadius: CGFloat?) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content.presentationCornerRadius(cornerRadius)
        } else if let cornerRadius {
            content.introspect(.sheet, on: .iOS(.v15, .v16)) {
                ($0 as? UISheetPresentationController)?.preferredCornerRadius = cornerRadius
            }
        }
    }
}

public extension View {
    func sheetCornerRadius(_ cornerRadius: CGFloat?) -> some View {
        self.modifier(SheetCornerRadiusModifier(cornerRadius))
    }
}
