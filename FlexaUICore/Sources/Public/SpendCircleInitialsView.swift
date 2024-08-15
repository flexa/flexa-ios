//
//  SpendCircleInitialsView.swift
//  FlexaUICore
//
//  Created by Rodrigo Ordeix on 8/30/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI

public struct SpendCircleInitialsView: View {
    var name: String
    var backgroundColor: Color = Color(.systemGray3)
    var textColor: Color = .white
    var size: CGFloat = 68
    var fontSize: CGFloat = 30

    private var initials: String {
      name.split(separator: " ")
        .compactMap { $0.first }
        .map { String($0).uppercased() }
        .joined()
    }

    public init(_ name: String,
                backgroundColor: Color = Color(.systemGray3),
                textColor: Color = .white,
                size: CGFloat = 68,
                fontSize: CGFloat = 30) {
        self.name = name
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.size = size
        self.fontSize = fontSize
    }

    public var body: some View {
        Text(initials)
            .font(.system(size: fontSize, weight: .semibold, design: .rounded))
            .foregroundColor(textColor)
            .frame(width: size, height: size)
            .background(backgroundColor)
            .clipShape(Circle())
    }
}
