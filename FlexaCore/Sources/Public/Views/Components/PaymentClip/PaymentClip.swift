//
//  PaymentClip.swift
//  FlexaCore
//
//  Created by Marcelo Korjenioski on 12/15/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import SwiftUI
import FlexaUICore
import SVGView
import Factory

public struct PaymentClip: View {
    @Environment(\.colorScheme) var colorScheme
    @Injected(\.flexaClient) var flexaClient
    public typealias Closure = () -> Void
    @Binding private var isShowing: Bool
    @Binding private var paymentDone: Bool
    @Binding private var payButtonEnabled: Bool
    @Binding private var assetSwitcherEnabled: Bool
    @State var showTransactionDetails: Bool = false

    public var didConfirm: Closure?
    public var didCancel: Closure?
    public var didSelect: Closure?
    private var value: String
    private var wallet: String
    private var asset: AssetWrapper
    private var walletIconURL: String = ""
    private var merchantLogoUrl: URL?
    private var merchantName = ""
    private var merchantColor: Color
    private var baseAmount: String
    private var fee: Fee?
    private var isLoading: Bool
    private var loadingTitle = ""
    private var isUsingAccountBalance: Bool
    var amount: String = ""

    var backgroundColor: Color {
        Color(colorScheme == .dark ? .systemBackground : .secondarySystemBackground)
    }

    private var flexaSvgUrl: URL? {
        let svgName = colorScheme == .dark ? "flexa-white" : "flexa"
        return Bundle.coreBundle.svgBundle.url(forResource: svgName, withExtension: "svg")
    }

    private var theme: FXTheme {
        flexaClient.theme
    }

    @ViewBuilder
    var leftHeaderView: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4.6)
                .fill(AngularGradient(colors: [.white, merchantColor], center: .center, angle: .degrees(180)))
                .frame(width: 24, height: 24)
            if let flexaSvgUrl {
                SVGView(contentsOf: flexaSvgUrl)
                    .frame(width: 52, height: 17)
            } else {
                Text(CoreStrings.Global.flexa)
                    .font(.title2.bold())
            }
        }
    }

    @ViewBuilder
    var rightHeaderView: some View {
        FlexaRoundedButton(.info) {
            showTransactionDetails = true
        }
    }

    @ViewBuilder
    var modal: some View {
        SpendDragModalView(titleColor: .primary,
                           grabberColor: Color(UIColor.systemGray4),
                           isShowing: $isShowing,
                           minHeight: 418,
                           enableBlur: true,
                           backgroundColor: backgroundColor,
                           leftHeaderView: leftHeaderView,
                           rightHeaderView: rightHeaderView,
                           presentationMode: .card,
                           didClose: { didCancel?() },
                           contentView:
                            PayNowContentView(paymentDone: $paymentDone,
                                              payButtonEnabled: $payButtonEnabled,
                                              assetSwitcherEnabled: $assetSwitcherEnabled,
                                              isLoading: isLoading,
                                              loadingTitle: loadingTitle,
                                              isUsingAccountBalance: isUsingAccountBalance,
                                              didSelect: didSelect,
                                              value: value,
                                              asset: asset,
                                              amount: amount,
                                              merchantLogoUrl: merchantLogoUrl,
                                              merchantName: merchantName,
                                              merchantColor: merchantColor,
                                              didConfirm: didConfirm)
        )
    }

    public init(isShowing: Binding<Bool>,
                value: String,
                baseAmount: String,
                wallet: String,
                asset: AssetWrapper,
                paymentDone: Binding<Bool>,
                payButtonEnabled: Binding<Bool>,
                assetSwitcherEnabled: Binding<Bool>,
                isLoading: Bool,
                loadingTitle: String,
                isUsingAccountBalance: Bool,
                merchantLogoUrl: URL?,
                merchantName: String,
                merchantColor: Color?,
                fee: Fee?,
                didConfirm: Closure?,
                didCancel: Closure?,
                didSelect: Closure?) {
        _isShowing = isShowing
        _paymentDone = paymentDone
        _payButtonEnabled = payButtonEnabled
        _assetSwitcherEnabled = assetSwitcherEnabled
        self.isLoading = isLoading
        self.loadingTitle = loadingTitle
        self.isUsingAccountBalance = isUsingAccountBalance
        self.didConfirm = didConfirm
        self.didCancel = didCancel
        self.didSelect = didSelect
        self.value = value
        self.wallet = wallet
        self.asset = asset
        self.merchantLogoUrl = merchantLogoUrl
        self.merchantName = merchantName
        self.merchantColor = merchantColor ?? .flexaTintColor
        self.baseAmount = baseAmount
        self.fee = fee
        self.updateAsset()
    }

    public var body: some View {
        let viewModel = TransactionAssetDetailsViewModel(
            displayMode: .transaction,
            asset: asset,
            mainAmount: value,
            fee: fee,
            hasAmount: true
        )
        if #available(iOS 16.0, *) {
            let detents: Set<PresentationDetent> = {
                if viewModel.accountBalanceCoversFullAmount {
                    return [.fraction(0.40)]
                }
                return [.fraction(viewModel.hasAccountBalance ? 0.45 : 0.35)]
            }()
            modal
            .persistentSystemOverlays(isShowing ? .hidden : .automatic)
                ZStack {}
                    .sheet(isPresented: $showTransactionDetails) {
                        transactionDetailsView(viewModel).presentationDetents(detents)
                            .environment(\.colorScheme, colorScheme)
                    }
        } else {
            modal
            SpendDragModalView(
                               isShowing: $showTransactionDetails,
                               minHeight: 436,
                               enableBlur: true,
                               enableHeader: false,
                               backgroundColor: backgroundColor,
                               presentationMode: .sheet,
                               contentView: transactionDetailsView(viewModel))
        }
    }

    func transactionDetailsView(_ viewModel: TransactionAssetDetailsViewModel) -> some View {
        NavigationView {
            TransactionAssetDetailsView(
                showView: $showTransactionDetails,
                viewModel: viewModel
            )
        }.environment(\.colorScheme, theme.interfaceStyle.colorSheme ?? colorScheme)
    }

    mutating func updateAsset() {
        amount = asset.balanceInLocalCurrency?.asCurrency ?? ""
    }
}

struct PayNowContentView: View {
    @Environment(\.presentationMode) var presentationMode

    public typealias Closure = () -> Void
    @Binding var paymentDone: Bool
    @Binding var payButtonEnabled: Bool
    @Binding var assetSwitcherEnabled: Bool
    var isLoading: Bool
    var loadingTitle: String
    var isUsingAccountBalance: Bool

    @State var showUpdatingBalanceAlert: Bool = false
    public var didSelect: Closure?
    var value: String
    var asset: AssetWrapper
    var amount: String = ""
    var merchantLogoUrl: URL?
    var merchantName = ""
    var merchantColor: Color
    var didConfirm: Closure?

    var showUpdatingBalanceButton: Bool {
        !payButtonEnabled && !isLoading && asset.isUpdatingBalance && !asset.enoughBalance(for: value.decimalValue ?? 0)
    }

    private var linearGradientColors: [Color] {
        guard !showUpdatingBalanceButton else {
            return [Color(UIColor.systemGray3)]
        }
        return [
            merchantColor.shiftingHue(by: 10),
            merchantColor,
            merchantColor.shiftingHue(by: -10)
        ]
    }

    private var linearGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: linearGradientColors),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var payNowButtonForeground: Color {
        showUpdatingBalanceButton ? .clear : .white
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ZStack(alignment: .center) {
                    RemoteImageView(
                        url: merchantLogoUrl,
                        content: { image in
                            image.resizable()
                                .frame(width: 48, height: 48)
                                .cornerRadius(6)
                                .aspectRatio(contentMode: .fill)
                                .scaledToFit()
                        },
                        placeholder: {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray)
                                .frame(width: 48, height: 48)
                        })
                }
                .frame(height: 68)
                .padding(.bottom, 4)
                Text(CoreStrings.Payment.payMerchant(merchantName))
                    .multilineTextAlignment(.center)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary.opacity(0.4))
                Text(value)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                VStack(spacing: paymentDone ? 10 : 18) {
                    if paymentDone {
                        linearGradient.mask(
                            Image(systemName: "checkmark.circle")
                                .resizable()
                        )
                        .frame(width: 50, height: 50, alignment: .center)
                        .transition(.scale)
                        linearGradient.mask(
                            Text(CoreStrings.Payment.done)
                                .multilineTextAlignment(.center)
                                .font(.body.weight(.semibold))
                        )
                        .frame(height: 20)
                        .transition(.move(edge: .bottom))
                    } else {
                        WalletSelectorView(asset: asset, usingAccountBalance: isUsingAccountBalance) {
                            didSelect?()
                        }.frame(idealHeight: 44)
                            .padding(.top, 10)
                            .disabled(!assetSwitcherEnabled)
                        ZStack {
                            Button {
                                didConfirm?()
                            } label: {
                                HStack(spacing: 10) {
                                    Spacer()
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                        Text(loadingTitle)
                                            .font(.body.weight(.semibold))
                                            .foregroundColor(.white)
                                    } else {
                                        Text(CoreStrings.Payment.payNow)
                                            .font(.body.weight(.semibold))
                                            .foregroundColor(payNowButtonForeground)
                                    }
                                    Spacer()
                                }.padding()

                            }
                            .disabled(!payButtonEnabled)
                            .opacity(payButtonEnabled ? 1 : 0.5)
                            .frame(idealHeight: 51)
                            .background(linearGradient)
                            .cornerRadius(13)
                            .overlay {
                                if showUpdatingBalanceButton {
                                    HStack {
                                        Text(CoreStrings.Payment.BalanceUnavailable.title)
                                        Image(systemName: "info.circle")
                                            .renderingMode(.template)
                                            .onTapGesture {
                                                showUpdatingBalanceAlert = true
                                            }
                                    }.flexaButton(
                                        background: Color.clear,
                                        textColor: .secondary
                                    )
                                }
                            }
                        }
                    }
                }.padding(.top, 20)
            }.background(Color.clear)
                .listRowBackground(Color.clear)
        }.listStyle(PlainListStyle())
        .padding(.top, 20)
        .alert(isPresented: $showUpdatingBalanceAlert) {
            UpdatingBalanceView.alert(asset.availableBalanceInLocalCurrency ?? 0)
        }
    }

    mutating func updateAsset() {
        amount = asset.balanceInLocalCurrency?.asCurrency ?? ""
    }
}
