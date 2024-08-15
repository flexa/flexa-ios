//
//  TransactionDetailsView.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 9/9/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore

struct TransactionDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Binding var showAssetsModal: Bool

    private var title: String
    private var url: URL?
    private var gradientColors: [Color]
    private var ticker: String = ""
    private var baseAmount: String = ""
    private var amount: String = ""
    private var exchangeRate: String = ""
    private var networkFee: String = ""
    private var baseNetworkFee: String = ""

    var backgroundColor: Color {
        Color(colorScheme == .dark ? .systemBackground : .secondarySystemBackground)
    }

    private let baseNetworkFeeColor = Color(hex: "#F7931A")

    public init(showAssetsModal: Binding<Bool>,
                title: String,
                url: URL?,
                gradientColors: [Color],
                ticker: String,
                price: String,
                amount: String,
                baseAmount: String,
                exchangeRate: String,
                networkFee: String,
                baseNetworkFee: String) {
        _showAssetsModal = showAssetsModal
        self.title = title
        self.url = url
        self.gradientColors = gradientColors
        self.baseAmount = L10n.Payment.Asset.ExchangeRate.amount(baseAmount, ticker)
        self.amount = amount
        self.exchangeRate = L10n.Payment.Asset.ExchangeRate.value(ticker, exchangeRate)
        self.networkFee = networkFee
        self.baseNetworkFee = baseNetworkFee
    }

    public var body: some View {
        NavigationView {
            List {
                Section(
                    footer:
                        Text(L10n.Payment.TransactionDetails.footer)
                ) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(amount)
                                .multilineTextAlignment(.leading)
                                .font(.title2.weight(.bold))
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(baseAmount)
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        SpendCircleImage(url, size: .circleImageSize, gradientColors: gradientColors)
                    }
                    VStack(alignment: .leading) {
                        HStack(spacing: .hStackSpacing) {
                            Image(systemName: "arrow.left.arrow.right")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.secondary)
                                .frame(width: .imageWidth, height: .imageHeight, alignment: .center)
                            Text(exchangeRate)
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        HStack(spacing: .hStackSpacing) {
                            Image(systemName: "network")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.secondary)
                                .frame(width: .imageWidth, height: .imageHeight, alignment: .center)
                            Text(networkFee)
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            if !baseNetworkFee.isEmpty {
                                ZStack {
                                    Text(baseNetworkFee)
                                        .font(.caption2.weight(.medium))
                                        .foregroundColor(baseNetworkFeeColor)
                                        .padding(EdgeInsets(top: 4, leading: 7, bottom: 4, trailing: 7))
                                }
                                .background(baseNetworkFeeColor).opacity(0.1)
                                .cornerRadius(6)
                            }

                        }
                    }
                }
            }
            .padding(.top, -24)
            .animation(.none)
            .background(backgroundColor)
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(
                leading: FlexaRoundedButton(
                    .settings,
                    symbolFont: .system(size: 13, weight: .bold),
                    size: CGSize(width: 26, height: 26)
                ),
                trailing:
                    Button(action: {
                        showAssetsModal = false
                    }, label: {
                        Text(L10n.Payment.done)
                            .font(.body.weight(.semibold))
                    }).padding(.trailing, 4)
            )
        }
    }
}

private extension CGFloat {
    static let hStackSpacing: CGFloat = 13
    static let imageWidth: CGFloat = 15
    static let imageHeight: CGFloat = 15
    static let circleImageSize: CGFloat = 42
}
