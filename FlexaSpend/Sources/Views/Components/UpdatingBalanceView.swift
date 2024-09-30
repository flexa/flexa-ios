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
            }.padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        }
        .listRowInsets(EdgeInsets(top: 24, leading: 0, bottom: 14, trailing: 0))
        .textCase(nil)
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
