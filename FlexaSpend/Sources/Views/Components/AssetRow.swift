//
//  AssetRow.swift
//  FlexaSpend
//
//  Created by Marcelo Korjenioski on 12/15/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore
import Factory

struct AssetRow: View {
    var title: String
    var subtitle: String
    var logoUrl: URL?
    var logoImage: UIImage?
    var gradientColors: [Color]
    var selected: Bool
    var enable: Bool
    var showInfo: () -> Void

    @State private var showAssetExchangeRateView: Bool = false

    init(asset: AssetWrapper,
         selected: Bool = false,
         enable: Bool = true,
         showInfo: @escaping () -> Void) {

        self.title = asset.assetSymbol
        if let balance = asset.usdBalance, asset.isUpdatingBalance {
            self.subtitle = L10n.Payment.Balance.title(balance.asCurrency).lowercased()
        } else {
            self.subtitle = asset.valueLabelTitleCase
        }
        self.logoUrl = asset.logoImageUrl
        self.logoImage = asset.logoImage
        self.gradientColors = []
        self.selected = selected
        self.enable = enable
        self.showInfo = showInfo
    }

    var body: some View {
        HStack(spacing: .hStackSpacing) {
            if enable {
                if let logoImage {
                    SpendCircleImage(Image(uiImage: logoImage), size: .circleImageSize, gradientColors: gradientColors)
                } else {
                    SpendCircleImage(logoUrl, size: .circleImageSize, gradientColors: gradientColors)
                }
                VStack(alignment: .leading, spacing: .vStackSpacing) {
                    Text(title)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: .titleFontSize, weight: .semibold))
                        .foregroundColor(Color.primary)
                    Text(subtitle)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: .descriptionFontSize, weight: .light))
                        .foregroundColor(Color.secondary)
                }
            } else {
                HStack(spacing: .hStackSpacing) {
                    SpendCircleImage(logoUrl, size: .circleImageSize)
                    VStack(alignment: .leading, spacing: .vStackSpacing) {
                        Text(title)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: .titleFontSize, weight: .semibold))
                            .foregroundColor(Color.primary)
                        Text(L10n.Payment.notEnough(title))
                            .multilineTextAlignment(.leading)
                            .font(.system(size: .descriptionFontSize, weight: .light))
                            .foregroundColor(Color.secondary)
                        Text(subtitle)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: .descriptionFontSize, weight: .light))
                            .foregroundColor(Color.secondary)
                    }
                }.opacity(0.5)
            }
            Spacer()
                Image(systemName: "info.circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.purple)
                    .frame(width: .imageWidth, height: .imageHeight, alignment: .center)
                    .onTapGesture {
                        showInfo()
                    }
        }
    }
}

private extension CGFloat {
    static let hStackSpacing: CGFloat = 8
    static let vStackSpacing: CGFloat = 1
    static let titleFontSize: CGFloat = 17
    static let descriptionFontSize: CGFloat = 15
    static let imageWidth: CGFloat = 26
    static let imageHeight: CGFloat = 26
    static let circleImageSize: CGFloat = 42
}
