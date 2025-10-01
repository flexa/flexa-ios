//
//  SpendAssetSwitcherButton.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 9/23/25.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

struct SpendAssetSwitcherButton: View {
    @Environment(\.theme) var mainTheme
    @Binding private var asset: AssetWrapper?
    private var action: () -> Void
    private var horizontalPadding: CGFloat {
        mainTheme.views.primary.padding ?? 0 + 6
    }

    init(asset: Binding<AssetWrapper?>, _ action: @escaping () -> Void) {
        self.action = action
        _asset = asset
    }

    var body: some View {
        if #available(iOS 26, *) {
            button
        } else {
            legacyButton
        }
    }

    @available(iOS 26, *)
    private var button: some View {
        HStack {
            Button {
                action()
            } label: {
                HStack {
                    Text(L10n.Payment.UsingTicker.subtitle(asset?.assetDisplayName ?? ""))
                        .font(.callout)
                    ZStack {
                        Image(systemName: "chevron.down")
                            .resizable()
                            .foregroundColor(.secondary)
                            .frame(width: 9, height: 5.5, alignment: .center)
                            .padding(.top, 1)
                            .font(.body.bold())
                    }.frame(width: 17, height: 17, alignment: .center)
                }
            }
            .buttonStyle(.glass)
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 40)
            Spacer()
        }
    }

    private var legacyButton: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(L10n.Payment.UsingTicker.subtitle(asset?.assetSymbol ?? ""))
                    .font(.callout)
                    .foregroundColor(Asset.payWithFlexaWalletSwitcherButton.swiftUIColor)
                    .bold()
                ZStack {
                    Image(systemName: "chevron.down.circle.fill")
                        .resizable()
                        .foregroundColor(Color(UIColor.secondarySystemFill))
                    Image(systemName: "chevron.down")
                        .resizable()
                        .foregroundColor(Asset.payWithFlexaWalletSwitcherButton.swiftUIColor)
                        .frame(width: 9, height: 5.5, alignment: .center)
                        .padding(.top, 1)
                        .font(.body.bold())
                }.frame(width: 17, height: 17, alignment: .center)

                Spacer()
            }

        }.padding(.horizontal, horizontalPadding)
            .padding(.top)
    }
}
