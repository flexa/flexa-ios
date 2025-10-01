//
//  CommerceSessionView.swift
//  FlexaCore
//
//  Created by Juan Olivera on 2/13/25.
//

import Foundation
import SwiftUI
import Factory
import FlexaUICore

public struct CommerceSessionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) var mainTheme
    @EnvironmentObject var flexaState: FlexaState

    @Injected(\.flexaClient) var flexaClient

    @StateObject private var viewModel: ViewModel
    @StateObject private var transactionAmountViewModel: TransactionAmountView.ViewModel
    @StateObject private var commerceSessionHandler: CommerceSessionHandler

    var sheetsTheme: FXTheme.Views.Sheet {
        mainTheme.views.sheet
    }

    var sheetBorderRadius: CGFloat {
        sheetsTheme.borderRadius
    }

    var sheetBackgroundColor: Color {
        sheetsTheme.backgroundColor
    }

    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)

        _transactionAmountViewModel = StateObject(
            wrappedValue: viewModel.transactionAmountViewModel
        )

        _commerceSessionHandler = StateObject(
            wrappedValue: viewModel.commerceSessionHandler
        )
    }

    public var body: some View {
        ZStack {
            legacyFlexcodeInputAmountSheet
            paymentCard
            assetsSwitcherSheet
            legacyFlexcodeCard
        }
        .interactiveDismissDisabled(viewModel.showPaymentModal || viewModel.showLegacyFlexcode)
        .onDisappear(perform: viewModel.stopWatching)
        .onChange(of: commerceSessionHandler.paymentCompleted, perform: viewModel.handlePaymentCompletedChange)
        .onChange(of: commerceSessionHandler.state, perform: viewModel.handleStateChange)
        .onChange(of: commerceSessionHandler.paymentEnabled, perform: viewModel.handlePaymentEnabledChange)
        .onChange(of: commerceSessionHandler.transactionIsInProgress, perform: viewModel.handleTransactionInProgressChange)
        .onReceive(viewModel.$isShowingModal, perform: showPaymentModalDidChange)
        .onTransactionSent(viewModel.transactionSentHandler)
    }
}

private extension CommerceSessionView {
    @ViewBuilder
    var legacyFlexcodeCard: some View {
        if let authorization = viewModel.commerceSession?.authorization {
            LegacyFlexcodeModal(isShowing: $viewModel.showLegacyFlexcode,
                                authorization: authorization,
                                value: viewModel.amountLabel,
                                brand: viewModel.transactionAmountViewModel.brand,
                                didConfirm: { },
                                didCancel: { viewModel.clear() })
            .zIndex(1)
        }
    }

    @ViewBuilder
    var paymentCard: some View {
        if let selectedAsset = viewModel.viewModelAsset.selectedAsset {
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
                        merchantColor: viewModel.merchantColor,
                        fee: viewModel.fee,
                        didConfirm: {
                viewModel.sendNextGen()
            }, didCancel: {
                viewModel.clear(canceled: true)
                if viewModel.isStandalone {
                    dismiss()
                }
            }, didSelect: {
                viewModel.viewModelAsset.showSelectedAssetDetail = false
                viewModel.viewModelAsset.amount = viewModel.amount
                viewModel.viewModelAsset.hasAmount = true
                viewModel.showAssetsModal = true
            }).zIndex(1)
        }
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
                    let canceled = !transactionAmountViewModel.isPaymentDone &&
                                    transactionAmountViewModel.cancelledByUser
                    viewModel.clearIfAuthorizationIsPending(canceled: canceled)
                }) {
                TransactionAmountView(
                    viewModel: transactionAmountViewModel,
                    viewModelAsset: viewModel.viewModelAsset
                )
                .environment(\.colorScheme, flexaClient.theme.interfaceStyle.colorSheme ?? colorScheme)
            }
    }

    @available(iOS 16.0, *)
    @ViewBuilder
    var assetsSwitcherSheet: some View {
        ZStack {}
            .sheet(isPresented: $viewModel.showAssetsModal) {
                VStack {
                    AssetsNavigationView(showAssetsModal: $viewModel.showAssetsModal,
                                         viewModelAsset: StateObject(wrappedValue: viewModel.viewModelAsset)) { selectedAsset in
                        viewModel.updateAsset(selectedAsset)
                        viewModel.showAssetsModal = false
                    }
                }
                .environment(\.colorScheme, flexaClient.theme.interfaceStyle.colorSheme ?? colorScheme)
                .sheetCornerRadius(sheetBorderRadius)
                .ignoresSafeArea()
                .presentationDetents([.fraction(0.40), .medium])
            }
    }

    @available(iOS, obsoleted: 16.0)
    var assetSwitcherCard: some View {
        AssetSelectionModal(isShowing: $viewModel.showAssetsModal,
                            viewModelAsset: viewModel.viewModelAsset,
                            updateAsset: { selectedAsset in
            viewModel.updateAsset(selectedAsset)
            viewModel.showAssetsModal = false
        }).zIndex(2)
    }
}

private extension CommerceSessionView {
    func showPaymentModalDidChange(_ show: Bool) {
        guard flexaState.isModalVisible != show else {
            return
        }
        withAnimation(Animation.default.delay(show ? 0 : 0.05)) {
            flexaState.isModalVisible = show
        }
    }
}
