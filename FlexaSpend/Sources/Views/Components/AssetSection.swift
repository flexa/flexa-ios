//
//  AssetSection.swift
//  FlexaSpend
//
//  Created by Marcelo Korjenioski on 12/15/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore

struct AssetSection: View {
    var title: String

    public init(_ title: String) {
        self.title = title
    }

    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(Color.primary.opacity(0.2)).frame(width: 20, height: 20)
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.callout.weight(.semibold))
                .foregroundColor(Color.primary)  // adapt to light/dark mode
        }.padding(.leading, -16)
            .padding(.bottom, 8)
    }
}
