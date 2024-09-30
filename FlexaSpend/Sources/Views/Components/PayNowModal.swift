//
//  PayNowModal.swift
//  FlexaSpend
//
//  Created by Marcelo Korjenioski on 12/15/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import SwiftUI
import FlexaUICore

struct PayNowModal: View {
    @Environment(\.colorScheme) var colorScheme
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
    private var baseAmount: String
    private var networkFee: String
    private var baseNetworkFee: String
    var amount: String = ""

    var backgroundColor: Color {
        Color(colorScheme == .dark ? .systemBackground : .secondarySystemBackground)
    }

    private let gradientStops: [Gradient.Stop] = [
            Gradient.Stop(color: Color(hex: "#80C3FF"), location: 0),
            Gradient.Stop(color: Color(hex: "#308DFF"), location: 0.31),
            Gradient.Stop(color: Color(hex: "#002EFF"), location: 0.5),
            Gradient.Stop(color: Color(hex: "#FFFFFF"), location: 0.5),
            Gradient.Stop(color: Color(hex: "#EBF0FF"), location: 0.62),
            Gradient.Stop(color: Color(hex: "#80FFFE"), location: 0.91)
    ]

    @ViewBuilder
    var leftHeaderView: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4.6)
                .fill(AngularGradient(gradient: Gradient(stops: gradientStops), center: .center))
                .frame(width: 24, height: 24)
            Text("flexa")
                .font(.title.bold())

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
        SpendDragModalView(titleColor: Asset.flexaIdTitle.swiftUIColor,
                           grabberColor: Asset.commonGrabber.swiftUIColor,
                           closeButtonColor: Asset.commonCloseButton.swiftUIColor,
                           isShowing: $isShowing,
                           minHeight: 436,
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
                                              didSelect: didSelect,
                                              value: value,
                                              asset: asset,
                                              amount: amount,
                                              merchantLogoUrl: merchantLogoUrl,
                                              merchantName: merchantName,
                                              didConfirm: didConfirm)
        )
    }

    var transactionDetailsView: some View {
        NavigationView {
            TransactionAssetDetailsView(
                showView: $showTransactionDetails,
                viewModel: TransactionAssetDetailsViewModel(
                displayMode: .dynamicTransaction,
                asset: asset,
                mainAmount: value,
                baseNetworkFeeColor: Color(hex: "#F7931A"))
            )
        }
    }

    init(isShowing: Binding<Bool>,
         value: String,
         baseAmount: String,
         networkFee: String,
         baseNetworkFee: String,
         wallet: String,
         asset: AssetWrapper,
         paymentDone: Binding<Bool>,
         payButtonEnabled: Binding<Bool>,
         assetSwitcherEnabled: Binding<Bool>,
         merchantLogoUrl: URL?,
         merchantName: String,
         didConfirm: Closure?,
         didCancel: Closure?,
         didSelect: Closure?) {
        _isShowing = isShowing
        _paymentDone = paymentDone
        _payButtonEnabled = payButtonEnabled
        _assetSwitcherEnabled = assetSwitcherEnabled
        self.didConfirm = didConfirm
        self.didCancel = didCancel
        self.didSelect = didSelect
        self.value = value
        self.wallet = wallet
        self.asset = asset
        self.merchantLogoUrl = merchantLogoUrl
        self.merchantName = merchantName
        self.networkFee = networkFee
        self.baseNetworkFee = baseNetworkFee
        self.baseAmount = baseAmount
        self.updateAsset()
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            modal
            .persistentSystemOverlays(isShowing ? .hidden : .automatic)
                ZStack {}
                    .sheet(isPresented: $showTransactionDetails) {
                        transactionDetailsView.presentationDetents([.fraction(0.35)])
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
                               contentView: transactionDetailsView)
        }
    }

    mutating func updateAsset() {
        amount = asset.valueLabel
    }
}

struct PayNowContentView: View {
    @Environment(\.presentationMode) var presentationMode

    public typealias Closure = () -> Void
    @Binding var paymentDone: Bool
    @Binding var payButtonEnabled: Bool
    @Binding var assetSwitcherEnabled: Bool
    @State var showUpdatingBalanceAlert: Bool = false
    public var didSelect: Closure?
    var value: String
    var asset: AssetWrapper
    var amount: String = ""
    var merchantLogoUrl: URL?
    var merchantName = ""
    var didConfirm: Closure?

    var showUpdatingBalanceButton: Bool {
        !payButtonEnabled && asset.isUpdatingBalance && !asset.enoughBalance(for: value.decimalValue ?? 0)
    }

    private let gradientStops: [Gradient.Stop] = [
        Gradient.Stop(color: Color(hex: "#006CFF"), location: 0),
        Gradient.Stop(color: Color(hex: "#2A00FF"), location: 0.51),
        Gradient.Stop(color: Color(hex: "#7800FF"), location: 1)
    ]

    private var linearGradient: LinearGradient {
        guard !showUpdatingBalanceButton else {
            return LinearGradient(colors: [Color(UIColor.systemGray3)], startPoint: .leading, endPoint: .trailing)
        }
        return LinearGradient(
            gradient: Gradient(stops: gradientStops),
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
                Text(L10n.Payment.payMerchant(merchantName))
                    .multilineTextAlignment(.center)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.primary.opacity(0.4))
                Text(value)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 48, weight: .bold))
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
                            Text(L10n.Payment.done)
                                .multilineTextAlignment(.center)
                                .font(.body.weight(.semibold))
                        )
                        .frame(height: 20)
                        .transition(.move(edge: .bottom))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                self.presentationMode.wrappedValue.dismiss()
                                UIViewController.topMostViewController?.dismiss(animated: true)
                            }
                        }
                    } else {
                        WalletSelectorView(asset: asset) {
                            didSelect?()
                        }.frame(idealHeight: 44)
                            .padding(.top, 10)
                            .disabled(!assetSwitcherEnabled)

                        ZStack {
                            Button {
                                didConfirm?()
                            } label: {
                                Text(L10n.Payment.payNow)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(payNowButtonForeground)
                            }
                            .cornerRadius(13)
                            .disabled(!payButtonEnabled)
                            .opacity(payButtonEnabled ? 1 : 0.5)
                            .frame(idealHeight: 51)
                            .background(linearGradient)
                            .cornerRadius(13)
                            .overlay {
                                if showUpdatingBalanceButton {
                                    HStack {
                                        Text(L10n.Payment.BalanceUnavailable.title)
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
        .padding(.top, 16)
        .alert(isPresented: $showUpdatingBalanceAlert) {
            UpdatingBalanceView.alert(asset.availableUSDBalance ?? 0)
        }
    }

    mutating func updateAsset() {
        amount = asset.valueLabel
    }
}
