//
//  PaymentView.swift
//  FlexaSpend
//
//  Created by Marcelo Korjenioski on 12/15/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore
import LocalAuthentication
import FlexaCore
import Factory
import Combine

struct SpendView: View {
    @Injected(\.flexaClient) var flexaClient
    @EnvironmentObject var modalState: SpendModalState
    @EnvironmentObject var linkData: UniversalLinkData
    @Environment(\.theme) var mainTheme
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    @StateObject private var viewModel: ViewModel
    @StateObject private var viewModelAsset: AssetSelectionViewModel
    @StateObject private var transactionAmountViewModel: TransactionAmountView.ViewModel

    @State private var showNotification = true
    @State private var selectedAssetIndex: Int
    @State private var selectedBrand: Brand?
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var url: URL?

    // MARK: - Initialization
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _viewModelAsset = StateObject(
            wrappedValue: viewModel.viewModelAsset
        )
        _transactionAmountViewModel = StateObject(
            wrappedValue: viewModel.transactionAmountViewModel
        )

        let index = viewModel.flexCodes.firstIndex(where: { $0.asset.assetId == viewModel.selectedAsset?.assetId }) ?? 0
        _selectedAssetIndex = State(initialValue: index)
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .center) {
                ScrollView {
                    VStack(spacing: viewModel.showInvalidAssetMessage ? 20 : 8) {
                        if viewModel.showInvalidAssetMessage {
                            Divider()
                            NoAssetsView(Container.shared.noAssetsViewModel(viewModel.invalidUserAssets))
                                .padding(.horizontal, padding)
                        } else if viewModel.missingAccounts {
                            ZStack {
                                RoundedRectangle(cornerRadius: containerBorderRadius)
                                    .foregroundColor(.white)
                                ProgressView()
                            }.frame(height: 300)
                                .padding(.horizontal, padding)
                                .padding(.top, 20)
                        } else {
                            assetSwitcherButton
                            flexcodeCarousel
                        }
                        if showNotification {
                            notificationsList
                        }
                        if viewModel.showLegacyFlexcodeList {
                            LegacyFlexcodeList(didSelect: { brand in
                                selectedBrand = brand
                                transactionAmountViewModel.clear()
                                transactionAmountViewModel.brand = brand
                                viewModel.showInputAmountView = true
                            })
                            .padding(.leading, padding)
                            .padding(.bottom, padding)
                        }
                    }
                    .padding(.top, viewModel.showInvalidAssetMessage ? 56 : 90)
                    .padding(.bottom, 100)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(mainBackgroundColor).ignoresSafeArea()
            .onChange(of: selectedAssetIndex, perform: flexcodeIndexDidChange)
            .onChange(of: viewModel.selectedAsset, perform: assetDidChange)
            .onReceive(viewModel.$isShowingModal, perform: showPaymentModalDidChange)
            .onError(error: $viewModel.error)
            .navigationTitle(Text(L10n.Payment.PayWithFlexa.title))
            .navigationBarTitleDisplayMode(viewModel.showInlineNavigationTitle ? .inline : .automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 8) {
                        NavigationMenu {
                            FlexaRoundedButton(.settings)
                        }
                        FlexaRoundedButton(.close, buttonAction: dismiss)
                    }
                }
            }
        }
        .interactiveDismissDisabled(viewModel.showPaymentModal || viewModel.showLegacyFlexcode)
        .navigationViewStyle(.stack)
        .navigationTitleAttributes(
            largeTitleAttributes: [.font: UIFont.systemFont(ofSize: 28, weight: .bold)],
            largeTitleLeftMargin: largeNavigationTitleLeftMargin
        )
        .onAppear {
            viewModel.loadAccounts()
            viewModel.startWatching()
            timer.upstream.connect().cancel()
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        }
        .onDisappear {
            viewModel.clear()
            viewModel.stopWatching()
            timer.upstream.connect().cancel()
        }
        .onReceive(timer) { _ in
            viewModel.refreshFlexcodes()
        }.onTransactionSent {
            viewModel.transactionSentHandler()
        }

        if #available(iOS 16, *) {
            assetsSwitcherSheet
        } else {
            assetSwitcherCard
        }

        legacyFlexcodeCard
        legacyFlexcodeInputAmountSheet
        paymentCard
    }

    private var flexcodeCarousel: some View {
        let width = UIScreen.main.bounds.width - 2 * padding
        var height: CGFloat = 300

        if viewModel.flexCodes.contains(where: { $0.isUpdatingBalance }) {
            height += 40
        }

        return SpendSnapCarousel(
            items: viewModel.flexCodes,
            selectedIndex: $selectedAssetIndex,
            itemSize: CGSize(
                width: width,
                height: height),
            spacing: 10,
            horizontalPadding: padding
        ) { code in
            SpendCodeView(
                viewModel: code,
                buttonAction: {
                    viewModelAsset.amount = 0
                    viewModelAsset.hasAmount = false
                    viewModel.viewModelAsset.showSelectedAssetDetail = true
                    viewModel.showAssetsModal = true
                }
            )
        }
        .padding(.vertical)
    }

    private var assetSwitcherButton: some View {
        Button {
            viewModelAsset.amount = 0
            viewModelAsset.hasAmount = false
            viewModelAsset.showSelectedAssetDetail = false
            viewModel.showAssetsModal = true
        } label: {
            HStack {
                Text(L10n.Payment.UsingTicker.subtitle(viewModel.selectedAssetSymbol))
                    .font(.callout)
                    .foregroundColor(Asset.payWithFlexaWalletSwitcherButton.swiftUIColor)
                    .bold()
                Image(systemName: "chevron.down.circle")
                    .resizable()
                    .foregroundColor(Asset.payWithFlexaWalletSwitcherButton.swiftUIColor)
                    .frame(width: 16, height: 16, alignment: .center)
                Spacer()
            }

        }.padding(.horizontal, largeNavigationTitleLeftMargin)
            .padding(.top)
    }

    private var notificationsList: some View {
        NotificationsList(viewModel: NotificationsList.ViewModel())
    }

}

// MARK: Theming
private extension SpendView {
    var primaryTheme: FXTheme.Views.Primary {
        mainTheme.views.primary
    }

    var sheetsTheme: FXTheme.Views.Sheet {
        mainTheme.views.sheet
    }

    var containerBorderRadius: CGFloat {
        mainTheme.containers.content.borderRadius
    }

    var padding: CGFloat {
        primaryTheme.padding ?? 0
    }

    var mainBackgroundColor: Color {
        primaryTheme.backgroundColor
    }

    var largeNavigationTitleLeftMargin: CGFloat {
        padding + 6
    }

    var sheetBorderRadius: CGFloat {
        sheetsTheme.borderRadius
    }

    var sheetBackgroundColor: Color {
        sheetsTheme.backgroundColor
    }
}

// MARK: Events
private extension SpendView {
    func updateAsset(_ selectedAsset: AssetWrapper) {
        viewModel.updateAsset(selectedAsset)
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
        UIViewController.topMostViewController?.dismiss(animated: true)
    }

    func flexcodeIndexDidChange(_ newValue: any Equatable) {
        guard 0..<viewModel.flexCodes.count ~= selectedAssetIndex, !viewModel.flexCodes.isEmpty else {
            return
        }
        let flexcode = viewModel.flexCodes[selectedAssetIndex]
        let selectedAsset = flexcode.asset
        viewModel.updateAsset(selectedAsset)
        viewModelAsset.selectedAsset = selectedAsset
    }

    func assetDidChange(_ newValue: any Equatable) {
        let index = viewModel.flexCodes.firstIndex { $0.asset.assetId == viewModel.selectedAsset?.assetId }
        if let index, index != selectedAssetIndex {
            selectedAssetIndex = index
        }
    }

    func showPaymentModalDidChange(_ show: Bool) {
        withAnimation(Animation.default.delay(show ? 0 : 0.05)) {
            modalState.visible = show
        }
    }
}

// MARK: Cards and Sheets
// We use sheets for iOS 16 and higher for the Asset Switcher. On older versions we use cards instead
// We use cards for the Payment Card and the Legacy Flexcode cards (on all versions)
private extension SpendView {
    @available(iOS 16.0, *)
    @ViewBuilder
    var assetsSwitcherSheet: some View {
        let detents: Set<PresentationDetent> = {
            if viewModel.viewModelAsset.accountBalanceCoversFullAmount {
                return [.fraction(0.40)]
            }
            return [.medium]
        }()
        ZStack {}
            .sheet(isPresented: $viewModel.showAssetsModal) {
                VStack {
                    AssetsNavigationView(showAssetsModal: $viewModel.showAssetsModal,
                                         viewModelAsset: _viewModelAsset) { selectedAsset in
                        viewModel.updateAsset(selectedAsset)
                        selectedAssetIndex = viewModel.flexCodes.firstIndex { $0.asset.assetId == selectedAsset.assetId } ?? 0
                        viewModel.showAssetsModal = false
                    }
                }
                .environment(\.colorScheme, flexaClient.theme.interfaceStyle.colorSheme ?? colorScheme)
                .sheetCornerRadius(sheetBorderRadius)
                .ignoresSafeArea()
                .presentationDetents(detents)
            }
    }

    @available(iOS, obsoleted: 16.0)
    var assetSwitcherCard: some View {
        AssetSelectionModal(isShowing: $viewModel.showAssetsModal,
                            viewModelAsset: viewModelAsset,
                            updateAsset: { selectedAsset in
            viewModel.updateAsset(selectedAsset)
            viewModel.showAssetsModal = false
        }).zIndex(2)
    }

    @ViewBuilder
    var legacyFlexcodeInputAmountSheet: some View {
        ZStack {}
            .onChange(of: transactionAmountViewModel.commerceSessionCreated) { created in
                if created {
                    self.viewModel.sendLegacy(commerceSession: transactionAmountViewModel.commerceSession)
                }
            }
            .sheet(
                isPresented: $viewModel.showInputAmountView,
                onDismiss: {
                    let canceled = !transactionAmountViewModel.isPaymentDone && transactionAmountViewModel.cancelledByUser
                    viewModel.clearIfAuthorizationIsPending(canceled: canceled)
                    viewModel.updateSelectedAsset()

                    if let selectedAssetId = viewModel.selectedAsset?.assetId {
                        let index = viewModel.flexCodes.firstIndex { $0.asset.assetId == selectedAssetId } ?? 0
                        selectedAssetIndex = index
                    }
                }) {
                TransactionAmountView(
                    viewModel: transactionAmountViewModel,
                    viewModelAsset: viewModelAsset
                )
                .environment(\.colorScheme, flexaClient.theme.interfaceStyle.colorSheme ?? colorScheme)
                .sheetCornerRadius(30)
            }
    }

    @ViewBuilder
    var legacyFlexcodeCard: some View {
        if let authorization = viewModel.commerceSession?.authorization {
            LegacyFlexcodeModal(isShowing: $viewModel.showLegacyFlexcode,
                                authorization: authorization,
                                value: viewModel.amountLabel,
                                brand: selectedBrand,
                                didConfirm: { },
                                didCancel: { viewModel.clear() })
            .zIndex(1)
        }
    }

    @ViewBuilder
    var paymentCard: some View {
        if let selectedAsset = viewModel.selectedAsset {
            PaymentClip(isShowing: $viewModel.showPaymentModal,
                        value: viewModel.amountLabel,
                        baseAmount: viewModel.baseAmountLabel,
                        wallet: "\(viewModel.assetConfig.selectedAssetId)",
                        asset: selectedAsset,
                        paymentDone: $viewModel.paymentCompleted,
                        payButtonEnabled: $viewModel.paymentButtonEnabled,
                        assetSwitcherEnabled: $viewModel.assetSwitcherEnabled,
                        isLoading: viewModel.transactionSent,
                        loadingTitle: viewModel.loadingTitle,
                        isUsingAccountBalance: viewModel.isUsingAccountBalance,
                        merchantLogoUrl: viewModel.merchantLogoUrl,
                        merchantName: viewModel.merchantName,
                        fee: viewModel.fee,
                        didConfirm: {
                viewModel.sendNextGen()
            }, didCancel: {
                viewModel.clear(canceled: true)
            }, didSelect: {
                viewModel.viewModelAsset.showSelectedAssetDetail = false
                viewModel.viewModelAsset.amount = viewModel.amount
                viewModel.viewModelAsset.hasAmount = true
                viewModel.showAssetsModal = true
            }).zIndex(1)
        }
    }
}
