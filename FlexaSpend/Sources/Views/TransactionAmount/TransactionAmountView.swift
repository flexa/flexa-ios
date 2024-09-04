//
//  TransactionAmountView.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 7/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore
import Factory

struct TransactionAmountView: View {
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    @State private var keySize: CGSize = .zero
    @State private var showTransactionDetails: Bool = false
    @State private var showAssetsModal = false
    @State private var shakeAmount: Int = 0
    @State private var animateShaking = true
    @StateObject var viewModel: ViewModel
    @StateObject private var viewModelAsset: AssetSelectionViewModel

    let grayColor = Color(UIColor.systemGray3)

    var gradientColors: [Color] {
        [
            viewModel.brandColor.shiftingHue(by: -10),
            viewModel.brandColor,
            viewModel.brandColor.shiftingHue(by: 10)
        ]
    }

    init(viewModel: ViewModel, viewModelAsset: AssetSelectionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _viewModelAsset = StateObject(wrappedValue: viewModelAsset)
    }

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { reader in
                Color.clear
                    .onAppear {
                        let width = (reader.size.width - 2 * .padding) / 3
                        keySize = CGSize(width: width, height: width)
                    }.onChange(of: reader.size) { size in
                        let width = (size.width - 2 * .padding) / 3
                        keySize = CGSize(width: width, height: width)
                    }
            }
            VStack(alignment: .center, spacing: 0) {
                brandLogo
                amountLabel
                    .padding(.top, .amountLabelTopPadding)
                    .shake(shakeAmount)
                assetSwitcherButton
                    .padding(.top, .assetSwitcherTopPadding)
                Spacer()
                numpadView
                payButton.padding(.top)
            }
            .padding([.horizontal, .bottom], .padding)
            .padding(.top, .topPadding)
            closeButton
        }
        .errorAlert(error: $viewModel.error)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.thinMaterial)
        .dragIndicator(true)
        transactionDetailsSheet
        assetSwitcher
    }

    var brandLogo: some View {
        RemoteImageView(
            url: viewModel.brandLogoUrl,
            content: { image in
                image.resizable()
                    .frame(width: .brandLogoSize, height: .brandLogoSize)
                    .cornerRadius(.brandLogoCornerRadius)
                    .aspectRatio(contentMode: .fill)
                    .scaledToFit()
            },
            placeholder: {
                RoundedRectangle(cornerRadius: .brandLogoCornerRadius)
                    .fill(Color.gray)
                    .frame(width: .brandLogoSize, height: .brandLogoSize)
            }
        )
    }

    var amountLabel: some View {
        Group {
            Text(viewModel.leftAmountText + viewModel.rightAmountText)
                .overlay {
                    Text("\(viewModel.leftAmountText)\(Text(viewModel.rightAmountText).foregroundColor(.clear))")
                        .foregroundStyle(linearGradient)
                }
        }
        .minimumScaleFactor(0.7)
        .lineLimit(1)
        .truncationMode(.middle)
        .font(.system(size: 78, weight: .semibold))
        .foregroundStyle(grayColor)
    }

    var linearGradient: LinearGradient {
        LinearGradient(
            colors: gradientColors,
            startPoint: .trailing,
            endPoint: .leading
        )
    }

    var assetSwitcherButton: some View {
        ZStack {
            Button {
                showAssetsModal = true
            } label: {
                HStack {
                    Text(L10n.Payment.UsingTicker.subtitle(viewModel.selectedAsset?.assetSymbol ?? ""))
                        .font(.callout)
                        .foregroundColor(grayColor)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.down.circle.fill")
                        .resizable()
                        .foregroundColor(grayColor)
                        .frame(width: 16, height: 16, alignment: .center)
                }
            }.opacity(viewModel.showAmountMessage ? 0 : 1)
                .disabled(viewModel.showAmountMessage)
                .transition(.opacity)
                .animation(.easeInOut(duration: 1), value: viewModel.showAmountMessage)

            Group {
                Text(viewModel.minimumAmountMessage)
                    .opacity(viewModel.showMinimumAmountMessage ? 1 : 0)
                    .animation(.easeInOut(duration: 1), value: viewModel.showMinimumAmountMessage)
                Text(viewModel.maximumAmountMessage)
                    .opacity(viewModel.showMaximumAmountMessage ? 1 : 0)
                    .animation(.easeInOut(duration: 1), value: viewModel.showMaximumAmountMessage)
            }.font(.callout)
                .foregroundColor(grayColor)
                .transition(.opacity)

        }
    }

    var numpadView: some View {
        VStack(spacing: 0) {
            numpadRow(keys: ["1", "2", "3"])
            numpadRow(keys: ["4", "5", "6"])
            numpadRow(keys: ["7", "8", "9"])
            numpadBottomRow()
        }
        .font(Font.system(size: 24, weight: .medium))
        .foregroundStyle(Color.primary)
        .disabled(viewModel.isLoading)
    }

    var closeButton: some View {
        HStack(alignment: .top) {
            Spacer()
            FlexaRoundedButton(.info) {
                self.showTransactionDetails = true
            }.padding()
        }.frame(maxWidth: .infinity)
    }

    var payButton: some View {
        ZStack {
            Button {
                viewModel.createCommerceSession()
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        if viewModel.showConfirmationButtonTitle {
                            Image(systemName: "faceid")
                                .renderingMode(.template)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        Text(viewModel.payButtonTitle)
                    }
                }.flexaButton(background: linearGradient, disabledTextColor: gradientColors.first?.opacity(0.4) ?? .white)
                    .animation(.default, value: viewModel.showConfirmationButtonTitle)
            }.disabled(!viewModel.paymentButtonEnabled)

            if !viewModel.paymentButtonEnabled {
                Button {
                    performShake()
                } label: {
                    Text("")
                        .flexaButton(background: Color.clear)
                }
            }
        }
    }

    @ViewBuilder
    var transactionDetailsSheet: some View {
        if #available(iOS 16.0, *) {
            ZStack {}
                .sheet(isPresented: $showTransactionDetails) {
                    transactionDetailsView.presentationDetents([.fraction(0.35)])
                }
        } else {
            var backgroundColor: Color {
                Color(colorScheme == .dark ? .systemBackground : .secondarySystemBackground)
            }

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

    @ViewBuilder
    var transactionDetailsView: some View {
        if let asset = viewModel.selectedAsset {
            NavigationView {
                TransactionAssetDetailsView(
                    showView: $showTransactionDetails,
                    tintColor: gradientColors.first ?? .purple,
                    viewModel: TransactionAssetDetailsViewModel(
                        displayMode: .dynamicTransaction,
                        asset: asset,
                        mainAmount: viewModel.amountText.digitsAndSeparator?.decimalValue?.asCurrency ?? "0",
                        baseNetworkFeeColor: Color(hex: "#F7931A"))
                )
            }
        }
    }

    private func numpadRow(keys: [String]) -> some View {
        HStack(spacing: 0) {
            Group {
                ForEach(keys, id: \.self) { key in
                    numpadDigitButton(key)
                }
            }

        }
    }

    private func numpadDigitButton(_ digit: String) -> some View {
        numpadDigitButton(key: .digit(digit)) {
            Text(digit)
        }
    }

    private func numpadDigitButton(key: ViewModel.KeyType, content: () -> some View) -> some View {
        Button {
            viewModel.keyPressed(key)
            if viewModel.showMaximumAmountMessage, key != .delete {
                performShake()
            }
        } label: {
            content()
        }.frame(width: keySize.width, height: keySize.height / 2)
    }

    private func numpadBottomRow() -> some View {
        HStack(spacing: 0) {
            numpadDigitButton(String(viewModel.decimalSeparator))
            numpadDigitButton("0")
            numpadDigitButton(key: .delete) {
                Image(systemName: "delete.left")
                    .renderingMode(.template)
                    .foregroundStyle(grayColor)
            }
        }
    }

    private func performShake() {
        guard animateShaking else {
            return
        }
        animateShaking = false
        withAnimation(Animation.easeOut(duration: 0.6)) {
            shakeAmount += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            animateShaking = true
        }
    }
}

// MARK: Asset Switcher
private extension TransactionAmountView {

    @ViewBuilder
    var assetSwitcher: some View {
        if #available(iOS 16, *) {
            assetsSwitcherSheet
        } else {
            assetSwitcherCard
        }
    }

    @available(iOS 16.0, *)
    var assetsSwitcherSheet: some View {
        ZStack {}
            .sheet(isPresented: $showAssetsModal) {
                VStack {
                    AssetsNavigationView(showAssetsModal: $showAssetsModal,
                                         viewModelAsset: _viewModelAsset) { selectedAsset in
                        viewModel.selectedAsset = selectedAsset
                        showAssetsModal = false
                    }
                }
                .environment(\.colorScheme, theme.interfaceStyle.colorSheme ?? colorScheme)
                .sheetCornerRadius(theme.views.sheet.borderRadius)
                .ignoresSafeArea()
                .presentationDetents([.medium])
            }
    }

    @available(iOS, obsoleted: 16.0)
    var assetSwitcherCard: some View {
        AssetSelectionModal(isShowing: $showAssetsModal,
                            viewModelAsset: viewModelAsset,
                            updateAsset: { selectedAsset in
            showAssetsModal = false
        }).zIndex(2)
    }
}

// MARK: Dimensions
private extension CGFloat {
    static let padding: CGFloat = 24
    static let topPadding: CGFloat = 32
    static let brandLogoSize: CGFloat = 44
    static let brandLogoCornerRadius: CGFloat = 6
    static let amountLabelTopPadding: CGFloat = 88
    static let assetSwitcherTopPadding: CGFloat = 22
}
