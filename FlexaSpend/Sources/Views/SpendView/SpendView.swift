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

struct SpendView: View {
    @Injected(\.flexaClient) var flexaClient
    @EnvironmentObject var modalState: SpendModalState
    @Environment(\.theme) var mainTheme
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    @StateObject private var viewModel: ViewModel
    @StateObject private var viewModelAsset: AssetSelectionViewModel
    @StateObject private var transactionAmountViewModel: TransactionAmountView.ViewModel

    @State private var showNotification = true
    @State private var showBrandDirectory = false
    @State private var userData: UserData?
    @State private var selectedAssetIndex: Int
    @State private var selectedBrand: Brand?

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
                        } else if viewModel.missingAppAccounts {
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
            .sheet(isPresented: $showBrandDirectory) { BrandView().ignoresSafeArea() }
            .onChange(of: selectedAssetIndex, perform: flexcodeIndexDidChange)
            .onChange(of: viewModel.selectedAsset, perform: assetDidChange)
            .onReceive(viewModel.$isShowingModal, perform: showPaymentModalDidChange)
            .onError(error: $viewModel.error)
            .navigationTitle(Text(L10n.Payment.PayWithFlexa.title))
            .navigationBarTitleDisplayMode(viewModel.showInlineNavigationTitle ? .inline : .automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 8) {
                        NavigationMenu(
                            showBrandDirectory: $showBrandDirectory,
                            showManageFlexaIDModal: $viewModel.showManageFlexaAccountSheet
                        )
                        FlexaRoundedButton(.close, buttonAction: dismiss)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .navigationTitleAttributes(
            largeTitleAttributes: [.font: UIFont.systemFont(ofSize: 28, weight: .bold)],
            largeTitleLeftMargin: largeNavigationTitleLeftMargin
        )
        .onAppear {
            viewModel.loadAppAccounts()
            viewModel.startWatching()

            FlexaIdentity
                .getUserData { result in
                    userData = result
                }
        }
        .onDisappear {
            viewModel.clear()
            viewModel.stopWatching()
        }

        if #available(iOS 16, *) {
            assetsSwitcherSheet
        } else {
            assetSwitcherCard
        }
        accountSettingsSheet
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
                    viewModel.viewModelAsset.showSelectedAssetDetail = true
                    viewModel.showAssetsModal = true
                }
            )
        }
        .padding(.vertical)
    }

    private var assetSwitcherButton: some View {
        Button {
            viewModel.viewModelAsset.showSelectedAssetDetail = false
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
// We use sheets for iOS 16 and higher for Account Settings and Asset Switcher. On older versions we use cards instead for both of them
// We use cards for the Payment Card and the Legacy Flexcode cards (on all versions)
private extension SpendView {
    var accountSettingsSheet: some View {
        ZStack {}
            .sheet(isPresented: $viewModel.showManageFlexaAccountSheet) {
                AccountView(viewModel: AccountView.ViewModel())
            }
    }

    @available(iOS 16.0, *)
    var assetsSwitcherSheet: some View {
        ZStack {}
            .sheet(isPresented: $viewModel.showAssetsModal) {
                VStack {
                    AssetsNavigationView(showAssetsModal: $viewModel.showAssetsModal,
                                         viewModelAsset: _viewModelAsset) { selectedAsset in
                        viewModel.updateSelectAsset()
                        viewModel.updateAsset(selectedAsset)
                        selectedAssetIndex = viewModel.flexCodes.firstIndex { $0.asset.assetId == selectedAsset.assetId } ?? 0
                        viewModel.showAssetsModal = false
                    }
                }
                .environment(\.colorScheme, flexaClient.theme.interfaceStyle.colorSheme ?? colorScheme)
                .sheetCornerRadius(sheetBorderRadius)
                .ignoresSafeArea()
                .presentationDetents([.medium])
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
            .onChange(of: transactionAmountViewModel.commerceSessionCreated) { _ in
                self.viewModel.signAndSendLegacy(commerceSession: transactionAmountViewModel.commerceSession)
            }
            .sheet(
                isPresented: $viewModel.showInputAmountView,
                onDismiss: {
                    viewModel.clearIfAuthorizationIsPending()
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
            PayNowModal(isShowing: $viewModel.showPaymentModal,
                        value: viewModel.amountLabel,
                        baseAmount: viewModel.baseAmountLabel,
                        networkFee: viewModel.networkFee,
                        baseNetworkFee: "",
                        wallet: "\(viewModel.assetConfig.selectedAssetId)",
                        asset: selectedAsset,
                        paymentDone: $viewModel.paymentCompleted,
                        payButtonEnabled: $viewModel.paymentButtonEnabled,
                        assetSwitcherEnabled: $viewModel.assetSwitcherEnabled,
                        merchantLogoUrl: viewModel.merchantLogoUrl,
                        merchantName: viewModel.merchantName,
                        didConfirm: {
                viewModel.signAndSend()
            }, didCancel: {
                viewModel.clear()
            }, didSelect: {
                viewModel.viewModelAsset.showSelectedAssetDetail = false
                viewModel.showAssetsModal = true
            }).zIndex(1)
        }
    }
}
