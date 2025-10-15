//
//  TransactionAmountView.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore
import Factory

// swiftlint:disable type_body_length
public struct TransactionAmountView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var keySize: CGSize = .zero
    @State private var showTransactionDetails: Bool = false
    @State private var showAssetsModal = false
    @State private var shakeAmount: Int = 0
    @State private var animateShaking = true
    @State private var showPopover = false
    @State private var showWebView = false
    @StateObject private var viewModel: ViewModel
    @StateObject private var viewModelAsset: AssetSelectionViewModel
    @Injected(\.flexaClient) private var flexaClient

    private var theme: FXTheme {
        flexaClient.theme
    }

    let grayColor = Color(
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? .secondaryLabel : .systemGray3
        }
    )

    var gradientColors: [Color] {
        if viewModel.hasPromotion {
            return [viewModel.brandColor]
        }
        return [
            viewModel.brandColor.shiftingHue(by: -10),
            viewModel.brandColor,
            viewModel.brandColor.shiftingHue(by: 10)
        ]
    }

    var disabledTextColor: Color {
        var color = Color.white
        if colorScheme == .light {
            color = viewModel.brandColor.shiftingHue(by: -10)
        }
        return color.opacity(0.4)
    }

    var amountLabelTopPadding: CGFloat {
        guard viewModel.hasPromotion else {
            return .amountLabelTopPadding
        }
        return .amountLabelTopPadding - .promotionHeight - .promotionTopPadding
    }

    var promotionViewBackgroundColor: Color {
        if viewModel.promotionApplies {
                return viewModel.brandColor.opacity(0.1)
        }
        return Color(hex: "D8D8D8").opacity(0.4)
    }

    public init(viewModel: ViewModel, viewModelAsset: AssetSelectionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _viewModelAsset = StateObject(wrappedValue: viewModelAsset)
    }

    public var body: some View {
        if Flexa.supportsGlass {
            NavigationView {
                content.toolbar {
                        toolBar
                }
            }
        } else {
            content
        }
        transactionDetailsSheet
        assetsSwitcherSheet
        alerts
    }

    var content: some View {
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
                if !Flexa.supportsGlass {
                    brandLogo
                }
                if viewModel.hasPromotion {
                    promotionView
                        .padding(.top, .promotionTopPadding)
                        .frame(height: .promotionHeight)
                }
                amountLabel
                    .padding(.top, amountLabelTopPadding)
                    .shake(shakeAmount)
                assetSwitcherContainer
                    .padding(.top, .assetSwitcherTopPadding)
                Spacer()
                numpadView
                payButton.padding(.top)
            }
            .padding([.horizontal, .bottom], .padding)
            .padding(.top, .topPadding)
            if !Flexa.supportsGlass {
                closeButton
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .setCustomBackground(colorScheme)
        .dragIndicator(true)
        .sheet(isPresented: $showWebView) {
            FlexaWebView(url: viewModel.promotion?.url)
        }.onTransactionSent {
            viewModel.transactionSent()
        }.onAppear {
            viewModel.loadAccount()
        }
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

    var promotionView: some View {
        ZStack {
            Label {
                if viewModel.promotionApplies {
                    Text(.init(viewModel.promotionText))
                        .font(Font.system(size: 15, weight: .medium))
                        .foregroundColor(viewModel.brandColor)
                        .tint(viewModel.brandColor)

                } else {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.primary.opacity(0.20))
                }
            } icon: {
                if viewModel.promotionApplies {
                    Image(systemName: "checkmark")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(viewModel.brandColor)
                } else {
                    Text(.init(viewModel.promotionText))
                        .foregroundColor(.primary.opacity(0.5))
                        .font(Font.system(size: 14, weight: .medium))
                        .tint(.primary.opacity(0.5))
                }
            }
            .environment(\.openURL, OpenURLAction { _ in
                self.showWebView = viewModel.promotion?.url != nil
                return .handled
            })
            .padding(.horizontal, 12)
            .padding(.vertical, 5)

        }.background(
            RoundedRectangle(cornerRadius: 17)
                .foregroundColor(promotionViewBackgroundColor)
        ).animation(.linear, value: viewModel.promotionApplies)
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

    @ViewBuilder
    var assetSwitcherButton: some View {
        let action: () -> Void = {
            viewModelAsset.amount = viewModel.decimalAmount - viewModel.promotionDiscount
            viewModelAsset.hasAmount = viewModel.hasAmount
            showAssetsModal = true
        }
        if Flexa.supportsGlass {
            glassAssetSwitcherButton(action)
        } else {
            legacyAssetSwitcherButton(action)
        }
    }

    var assetSwitcherContainer: some View {
        ZStack {
            assetSwitcherButton
                .opacity(viewModel.showAmountMessage ? 0 : 1)
                .disabled(viewModel.showAmountMessage || viewModel.isLoading)
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

    @ToolbarContentBuilder
    var toolBar: some ToolbarContent {
        if Flexa.supportsGlass {
            ToolbarItem(placement: .principal) {
                brandLogo
            }
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.isLoading {
                    FlexaRoundedButton(.close) {
                        viewModel.cancelledByUser = true
                        dismiss()
                    }.padding()
                } else {
                    FlexaRoundedButton(.info) {
                        self.showTransactionDetails = true
                    }.padding()
                }
            }
        }
    }

    @ViewBuilder
    var closeButton: some View {
        HStack(alignment: .top) {
            Spacer()
            if viewModel.isLoading {
                FlexaRoundedButton(.close) {
                    viewModel.cancelledByUser = true
                    dismiss()
                }.padding()
            } else {
                FlexaRoundedButton(.info) {
                    self.showTransactionDetails = true
                }.padding()
            }

        }.frame(maxWidth: .infinity)
    }

    var payButton: some View {
        ZStack {
            Button {
                viewModel.createOrUpdateCommerceSession()
            } label: {
                HStack(spacing: 10) {
                    if viewModel.isPaymentDone {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                        Text(viewModel.payButtonTitle)
                            .foregroundColor(.white)
                    } else if viewModel.isLoading {
                        ProgressView().tint(.white)
                        Text(viewModel.payButtonTitle)
                            .foregroundColor(.white)
                    } else {
                        if viewModel.showConfirmationButtonTitle && !viewModel.showNoBalanceButton {
                            Image(systemName: "faceid")
                                .renderingMode(.template)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        Text(viewModel.payButtonTitle)
                    }

                }.flexaButton(
                    background: linearGradient,
                    disabledTextColor: disabledTextColor,
                    disabledOpacity: colorScheme == .dark ? 0.5 : 0.2
                )
                .animation(.default, value: viewModel.showConfirmationButtonTitle)
            }.disabled(!viewModel.paymentButtonEnabled)

            if !viewModel.paymentButtonEnabled {
                Button {
                    performShake()
                } label: {
                    if viewModel.showNoBalanceButton {
                        HStack {
                            Text(Strings.Buttons.BalanceUnavailable.title)
                            Image(systemName: "info.circle")
                                .renderingMode(.template)
                                .onTapGesture {
                                    showPopover = true
                                }
                                .updatingBalancePopover($showPopover, balanceAvailable: viewModel.availableUSDBalance)
                        }.flexaButton(
                            background: Color.clear,
                            textColor: disabledTextColor
                        )
                    } else {
                        Text("")
                            .flexaButton(background: Color.clear)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var transactionDetailsSheet: some View {
        if #available(iOS 16.0, *) {
            let detents: Set<PresentationDetent> = {
                if viewModel.accountBalanceCoversFullAmount {
                    return [.fraction(0.40)]
                }
                return [.fraction(viewModel.hasAccountBalance ? 0.45 : 0.35)]
            }()
            ZStack {}
                .sheet(isPresented: $showTransactionDetails) {
                    transactionDetailsView.presentationDetents(detents)
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
                    tintColor: viewModel.brandColor,
                    viewModel: TransactionAssetDetailsViewModel(
                        displayMode: .transaction,
                        asset: asset,
                        mainAmount: viewModel.amountText.digitsAndSeparator?.decimalValue?.asCurrency ?? "0",
                        discount: viewModel.promotionApplies ? viewModel.promotionDiscount : nil,
                        fee: viewModel.fee,
                        hasAmount: true
                    )
                )
            }.environment(\.colorScheme, theme.colorScheme ?? colorScheme)
        }
    }

    @ViewBuilder
    var alerts: some View {
        blankView()
            .errorAlert(error: $viewModel.error)
        if #unavailable(iOS 16.4) {
            blankView()
                .alert(isPresented: $showPopover) {
                    UpdatingBalanceView.alert(viewModel.availableUSDBalance)
                }
        }
    }

    private func legacyAssetSwitcherButton(_ action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Text(viewModel.assetSwitcherTitle)
                    .font(.callout)
                    .foregroundColor(grayColor)
                    .fontWeight(.semibold)
                Image(systemName: "chevron.down.circle.fill")
                    .resizable()
                    .foregroundColor(grayColor)
                    .frame(width: 16, height: 16, alignment: .center)
            }
        }
    }

    private func glassAssetSwitcherButton(_ action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Text(viewModel.assetSwitcherTitle)
                    .font(.callout)
                    .fontWeight(.semibold)
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
        .glassButtonStyle()
    }

    private func blankView() -> some View {
        Text("")
            .frame(width: 0, height: 0)
            .hidden()
            .alertTintColor(.flexaTintColor)
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
// swiftlint:enable type_body_length

// MARK: Asset Switcher
private extension TransactionAmountView {
    @available(iOS 16.0, *)
    @ViewBuilder
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
                .presentationDetents([.fraction(0.40), .medium])
            }
    }
}

private extension View {
    @ViewBuilder
    func updatingBalancePopover(_ showPopover: Binding<Bool>, balanceAvailable: Decimal) -> some View {
        if #available(iOS 16.4, *) {
            popover(isPresented: showPopover, arrowEdge: .bottom) {
                UpdatingBalanceView(backgroundColor: Color(UIColor.tertiarySystemBackground), amount: balanceAvailable)
                    .frame(minHeight: 120)
                    .presentationCompactAdaptation((.popover))
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func setCustomBackground(_ colorScheme: ColorScheme) -> some View {
        if colorScheme == .dark {
            self.background(Container.shared.flexaClient().theme.views.primary.backgroundColor)
        } else {
            self.background(.thinMaterial)
        }
    }
}

// MARK: Dimensions
private extension CGFloat {
    static let padding: CGFloat = 24
    static let topPadding: CGFloat = 32
    static let brandLogoSize: CGFloat = 44
    static let brandLogoCornerRadius: CGFloat = 6
    static let promotionTopPadding: CGFloat = 17
    static let promotionHeight: CGFloat = 32
    static let amountLabelTopPadding: CGFloat = 88
    static let assetSwitcherTopPadding: CGFloat = 22
}
