//
//  WalletSelectorView.swift
//  FlexaSpend
//
//  Created by Marcelo Korjenioski on 12/15/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import SwiftUI
import FlexaUICore

struct WalletSelectorView: View {
    @Environment(\.colorScheme) var colorScheme
    var asset: AssetWrapper
    var buttonAction: () -> Void
    var backgroundColor: Color {
        Color(colorScheme == .dark ? UIColor.tertiarySystemFill.withAlphaComponent(0.16) : .white)
    }

    init(asset: AssetWrapper,
         buttonAction: @escaping () -> Void) {
        self.buttonAction = buttonAction
        self.asset = asset
    }

    var body: some View {
        Button {
            buttonAction()
        } label: {
            HStack(alignment: .center) {
                Text(L10n.Payment.using)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                if let logoImage = asset.logoImage {
                    SpendCircleImage(Image(uiImage: logoImage), size: 18, gradientColors: asset.gradientColors).padding(4)
                } else {
                    SpendCircleImage(asset.logoImageUrl, size: 18, gradientColors: asset.gradientColors).padding(4)
                }

                Text(asset.assetDisplayName)
                    .lineLimit(1)
                    .font(.body)
                    .foregroundColor(.secondary)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 14, height: 15, alignment: .center)
            }.padding([.horizontal], 16)
                .frame(height: 44, alignment: .center)
                .modifier(RoundedView(color: backgroundColor))
        }
    }
}
