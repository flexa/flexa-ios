//
//  UpdatingBalanceView.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 9/27/23.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

struct UpdatingBalanceView: View {
    private typealias Strings = L10n.UpdatingBalance

    var backgroundColor: Color
    var amount: Decimal
    var horizontalPadding: CGFloat
    var verticalPadding: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(backgroundColor)
            HStack(alignment: .top, spacing: 11) {
                Image(systemName: "hourglass")
                    .font(.system(size: 42))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.title)
                        .font(.body.weight(.semibold))
                        .foregroundColor(.primary)
                    Text(.init(Strings.text(amount.asCurrency)))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .minimumScaleFactor(0.5)
                }
                .multilineTextAlignment(.leading)
            }.padding(.vertical, verticalPadding)
                .padding(.horizontal, horizontalPadding)
        }
        .textCase(nil)
    }

    init(backgroundColor: Color,
         amount: Decimal,
         horizontalPadding: CGFloat = 16,
         verticalPadding: CGFloat = 12) {
        self.backgroundColor = backgroundColor
        self.amount = amount
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
    }

    static func alert(_ amount: Decimal) -> Alert {
        Alert(
            title: Text(Strings.title),
            message: Text(.init(Strings.text(amount.asCurrency))),
            dismissButton: .default(
                Text(L10n.Common.ok)
            )
        )
    }
}
