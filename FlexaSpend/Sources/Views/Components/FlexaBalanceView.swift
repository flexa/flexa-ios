//
//  FlexaBalanceView.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 10/31/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

struct FlexaBalanceView: View {
    enum IconAlignment {
        case top, left, right
    }

    @Environment(\.theme.tables) var tablesTheme
    let iconAlignment: IconAlignment
    let title: String
    let subtitle: String

    private var lineLimit: Int? {
        iconAlignment == .top ? nil : 1
    }

    private var textAlignment: TextAlignment {
        iconAlignment == .top ? .center : .leading
    }

    private var iconSize: CGFloat {
        iconAlignment == .top ? 64 : 42
    }

    init(iconAlignment: IconAlignment = .left,
         title: String,
         subtitle: String) {
        self.iconAlignment = iconAlignment
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(spacing: 8) {
            if iconAlignment == .top {
                VStack(alignment: .center, spacing: 4) {
                    iconView
                    balanceTitleView
                        .padding(.top, 10)
                    balanceSubtitleView
                }.frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            } else if iconAlignment == .left {
                iconView
                balanceInfoView
            } else {
                balanceInfoView
                Spacer()
                iconView
            }
        }
        .listRowBackground(
            Rectangle()
                .fill(Color(UIColor.quaternarySystemFill))
                .cornerRadius(cornerRadius, corners: .allCorners)
        )
    }

    private var iconView: some View {
        Image(systemName: "checkmark.circle.fill")
            .resizable()
            .foregroundColor(Color(UIColor.tertiaryLabel))
            .frame(width: iconSize, height: iconSize)

    }

    private var balanceInfoView: some View {
        VStack(alignment: .leading, spacing: 1) {
            balanceTitleView
            balanceSubtitleView
        }
    }

    private var balanceTitleView: some View {
        Text(title)
            .multilineTextAlignment(textAlignment)
            .lineLimit(lineLimit)
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(Color.primary)
            .minimumScaleFactor(0.7)
    }

    private var balanceSubtitleView: some View {
        Text(subtitle)
            .multilineTextAlignment(textAlignment)
            .lineLimit(lineLimit)
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(Color.secondary)
            .minimumScaleFactor(0.7)
    }
}

private extension FlexaBalanceView {
    var cornerRadius: CGFloat {
        tablesTheme.cell.borderRadius > 0 ? tablesTheme.cell.borderRadius : tablesTheme.borderRadius
    }
}
