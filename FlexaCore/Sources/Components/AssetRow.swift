//
//  AssetRow.swift
//  FlexaCore
//
//  Created by Marcelo Korjenioski on 12/15/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import SwiftUI
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

        if Flexa.supportsGlass {
            self.title = asset.assetDisplayName
        } else {
            self.title = asset.assetSymbol
        }
        if let balance = asset.balanceInLocalCurrency?.asCurrency {
            if asset.isUpdatingBalance {
                self.subtitle = CoreStrings.Payment.Balance.title(balance)
            } else {
                self.subtitle = CoreStrings.Payment.CurrencyAvaliable.title(balance)
            }
        } else {
            self.subtitle = ""
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
                    SpendCircleImage(
                        Image(uiImage: logoImage),
                        size: .circleImageSize,
                        gradientColors: gradientColors,
                        placeholderColor: .clear
                    )
                } else if let logoUrl {
                    SpendCircleImage(
                        logoUrl,
                        size: .circleImageSize,
                        gradientColors: gradientColors,
                        placeholderColor: .clear
                    )
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
                    if let logoUrl {
                        SpendCircleImage(logoUrl, size: .circleImageSize, placeholderColor: .clear)
                    } else if let logoImage {
                        SpendCircleImage(Image(uiImage: logoImage), size: .circleImageSize, placeholderColor: .clear)
                    }
                    VStack(alignment: .leading, spacing: .vStackSpacing) {
                        Text(title)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: .titleFontSize, weight: .semibold))
                            .foregroundColor(Color.primary)
                        Text(CoreStrings.Payment.notEnough(title))
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
            rightAccessoryView
                .onTapGesture {
                    showInfo()
                }
        }
    }

    @ViewBuilder
    private var rightAccessoryView: some View {
        if Flexa.supportsGlass {
            Image(systemName: "ellipsis")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.primary)
                .frame(width: .imageWidth, height: .imageHeight, alignment: .center)
        } else {
            Image(systemName: "info.circle")
                .resizable()
                .scaledToFit()
                .foregroundColor(.flexaTintColor)
                .frame(width: .imageWidth, height: .imageHeight, alignment: .center)

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
