//
//  WalletSelectorView.swift
//  FlexaCore
//
//  Created by Marcelo Korjenioski on 12/15/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import SwiftUI

struct WalletSelectorView: View {
    @Environment(\.colorScheme) var colorScheme
    var asset: AssetWrapper
    var usingAccountBalance: Bool
    var buttonAction: () -> Void
    var backgroundColor: Color {
        Color(colorScheme == .dark ? UIColor.tertiarySystemFill.withAlphaComponent(0.16) : .white)
    }

    init(asset: AssetWrapper,
         usingAccountBalance: Bool = false,
         buttonAction: @escaping () -> Void) {
        self.buttonAction = buttonAction
        self.asset = asset
        self.usingAccountBalance = usingAccountBalance
    }

    var body: some View {
        Button {
            buttonAction()
        } label: {
            HStack(alignment: .center) {
                Text(CoreStrings.Payment.using)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()

                if usingAccountBalance {
                    accountBalanceView
                } else {
                    assetView
                }
                Image(systemName: "chevron.up.chevron.down")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 14, height: 15, alignment: .center)
            }.padding([.horizontal], 16)
                .frame(height: 44, alignment: .center)
                .modifier(RoundedView(color: backgroundColor, cornerRadius: 10))

        }
    }

    @ViewBuilder
    private var accountBalanceView: some View {
        Text(CoreStrings.Payment.YourFlexaAccount.title)
            .lineLimit(1)
            .font(.body)
            .foregroundColor(.secondary)
    }

    @ViewBuilder
    private var assetView: some View {
        if let logoImage = asset.logoImage {
            SpendCircleImage(
                Image(uiImage: logoImage),
                size: 18,
                gradientColors: asset.gradientColors,
                placeholderColor: .clear
            ).padding(4)
        } else {
            SpendCircleImage(
                asset.logoImageUrl,
                size: 18,
                gradientColors: asset.gradientColors,
                placeholderColor: .clear
            ).padding(4)
        }

        Text(asset.assetDisplayName)
            .lineLimit(1)
            .font(.body)
            .foregroundColor(.secondary)
    }
}
