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
    @EnvironmentObject var linkData: UniversalLinkData
    @Environment(\.theme) var mainTheme
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel: ViewModel
    @StateObject private var viewModelAsset: AssetSelectionViewModel
    @StateObject private var transactionAmountViewModel: TransactionAmountView.ViewModel

    @State private var showNotification = true
    @State private var selectedAssetIndex: Int
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var paymentCompleted: Bool = false

    var url: URL?

    // MARK: - Initialization
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)

        _viewModelAsset = StateObject(
            wrappedValue: viewModel.commerceSessionViewModel.viewModelAsset
        )
        _transactionAmountViewModel = StateObject(
            wrappedValue: viewModel.commerceSessionViewModel.transactionAmountViewModel
        )

        let index = viewModel.flexCodes.firstIndex(where: { $0.asset.assetId == viewModel.selectedAsset?.assetId }) ?? 0
        _selectedAssetIndex = State(initialValue: index)
    }

    var body: some View {
        if viewModel.isSignedIn || viewModel.isStandAlone {
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
                                    viewModel.brandSelected(brand)
                                })
                                .padding(.leading, brandsListHorizontalPadding)
                                .padding(.bottom, padding)
                            }
                        }
                        .padding(.top, viewModel.showInvalidAssetMessage ? 56 : 90)
                        .padding(.bottom, 100)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .background(mainBackgroundColor).ignoresSafeArea()
                .navigationTitle(Text(L10n.Payment.PayWithFlexa.title))
                .navigationBarTitleDisplayMode(viewModel.showInlineNavigationTitle ? .inline : .automatic)
                .toolbar {
                    SpendToolbar(dismissView)
                }
            }
            .navigationViewStyle(.stack)
            .navigationTitleAttributes(
                largeTitleAttributes: [.font: UIFont.systemFont(ofSize: 28, weight: .bold)],
                largeTitleLeftMargin: largeNavigationTitleLeftMargin
            )
            .onAppear {
                viewModel.setup()
                timer.upstream.connect().cancel()
                timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            }
            .onDisappear {
                viewModel.clear()
                timer.upstream.connect().cancel()
            }
            .onReceive(timer) { _ in
                viewModel.refreshFlexcodes()
            }
            .onChange(of: viewModelAsset.selectedAsset) { value in
                if let selectedAsset = value {
                    assetDidChange(selectedAsset)
                }
            }
            .onChange(of: viewModel.commerceSessionViewModel.accounts) { _ in
                viewModel.handleAccountsDidUpdate()
            }
            .onChange(of: viewModel.commerceSessionViewModel.error) { error in
                viewModel.setError(error?.base)
            }
            .onChange(of: selectedAssetIndex, perform: flexcodeIndexDidChange)
            .onChange(of: viewModel.selectedAsset, perform: assetDidChange)
            .onError(error: $viewModel.error)

            CommerceSessionView(viewModel: viewModel.commerceSessionViewModel)
        } else {
            emptyView
        }
    }

    private var emptyView: some View {
        ZStack {
            mainBackgroundColor
            ProgressView().tint(.flexaTintColor)
        }
        .onSpendSelected {
            DispatchQueue.main.async {
                viewModel.isSignedIn = FlexaIdentity.isSignedIn
            }
        }
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
                    viewModel.showAssetInfo()
                }
            )
        }
        .padding(.vertical)
    }

    private var assetSwitcherButton: some View {
        SpendAssetSwitcherButton(asset: $viewModel.commerceSessionViewModel.viewModelAsset.selectedAsset) {
            viewModelAsset.amount = 0
            viewModelAsset.hasAmount = false
            viewModelAsset.showSelectedAssetDetail = false
            viewModel.commerceSessionViewModel.showAssetsModal = true
        }
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

    var brandsListHorizontalPadding: CGFloat {
        if Flexa.supportsGlass {
            return 0
        } else {
            return padding
        }
    }

    var mainBackgroundColor: Color {
        primaryTheme.backgroundColor
    }

    var largeNavigationTitleLeftMargin: CGFloat {
        if Flexa.supportsGlass {
            return padding
        } else {
            return padding + 6
        }
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

    func dismissView() {
        dismiss()
        UIViewController.topMostViewController?.dismiss(animated: true)
    }

    func flexcodeIndexDidChange(_ newValue: any Equatable) {
        guard 0..<viewModel.flexCodes.count ~= selectedAssetIndex, !viewModel.flexCodes.isEmpty else {
            return
        }
        let flexcode = viewModel.flexCodes[selectedAssetIndex]
        let selectedAsset = flexcode.asset
        viewModel.commerceSessionViewModel.viewModelAsset.selectedAsset = selectedAsset
    }

    func assetDidChange(_ newValue: any Equatable) {
        let index = viewModel.flexCodes.firstIndex { $0.asset.assetId == viewModel.selectedAsset?.assetId }
        if let index, index != selectedAssetIndex {
            selectedAssetIndex = index
        }
    }
}
