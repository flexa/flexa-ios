import Foundation
import SwiftUI
import FlexaUICore
import SwiftUIIntrospect

struct AssetSelectionView: View {
    public typealias ClosureAsset = (AssetWrapper) -> Void
    @Environment(\.theme.views.sheet) var theme
    @Environment(\.theme.tables) var tableTheme
    @Environment(\.theme.tables.cell) var cellsTheme

    var didSelect: ClosureAsset?

    @Binding var showAssetsModal: Bool
    @State private var isAssetExchangeRateViewPresented = false
    @State private var transactionAssetDetailsView: TransactionAssetDetailsView?
    @StateObject private var viewModel: AssetSelectionViewModel

    init(showAssetsModal: Binding<Bool>,
         viewModel: StateObject<AssetSelectionViewModel>,
         didSelect: ClosureAsset?) {
        _showAssetsModal = showAssetsModal
        self.didSelect = didSelect
        _viewModel = viewModel
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            List {
                ForEach($viewModel.appAccounts, id: \.accountId) { appAccount in
                    ForEach(appAccount.accountAssets, id: \.assetId) { asset in
                        if !viewModel.enoughAmount(for: asset.wrappedValue) && viewModel.hideShortBalances {
                            EmptyView()
                        } else {
                            assetRow(AssetWrapper(appAccount: appAccount.wrappedValue, asset: asset.wrappedValue))
                                .listRowSeparator(.hidden, edges: hidingSeparatorEdges(for: asset.wrappedValue))
                                .listRowSeparatorTint(tableTheme.separator.color)
                        }
                    }
                }
                if viewModel.amount > 0 {
                    Toggle(L10n.Payment.HideShortBalances.title, isOn: $viewModel.hideShortBalances)
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundColor(Color.primary)
                        .toggleStyle(SwitchToggleStyle(tint: Color.gray))
                }
            }
            .listStyle(PlainListStyle())
            .listRowSpacing(tableTheme.cellSpacing)

            .shadow(color: tableTheme.shadow.color,
                    radius: tableTheme.shadow.radius,
                    x: tableTheme.shadow.x,
                    y: tableTheme.shadow.y)
            .background(NavigationLink("",
                                       destination: transactionAssetDetailsView,
                                       isActive: $isAssetExchangeRateViewPresented).hidden())
            .padding(.horizontal, listPadding)
        }.animation(.none)
            .onAppear {
                if let asset = viewModel.selectedAsset, viewModel.showSelectedAssetDetail {
                    showAssetInfo(asset)
                    viewModel.showSelectedAssetDetail = false
                }
            }
    }

    func showAssetInfo(_ asset: AssetWrapper) {
        transactionAssetDetailsView = TransactionAssetDetailsView(
            showView: $showAssetsModal,
            viewModel: TransactionAssetDetailsViewModel(
                displayMode: .asset,
                asset: asset,
                networkFee: L10n.Payment.Asset.ExchangeRate.noNetworkFee))

        if viewModel.showSelectedAssetDetail {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                isAssetExchangeRateViewPresented = true
            }
        } else {
            isAssetExchangeRateViewPresented = true
        }
    }

    @ViewBuilder
    private func assetRow(_ asset: AssetWrapper) -> some View {
        Button {
            if viewModel.enoughAmount(asset) {
                showAssetsModal = false
                viewModel.updateSelectedAsset(asset)
                if let selectedAsset = viewModel.selectedAsset {
                    didSelect?(selectedAsset)
                }
            }
        } label: {
            AssetRow(asset: asset,
                     selected: viewModel.isAssetSelected(asset),
                     enable: viewModel.enoughAmount(asset),
                     showInfo: {
                showAssetInfo(asset)
            })
        }.listRowBackground(
            Rectangle()
                .fill(cellBackgroundColor)
                .cornerRadius(theme.borderRadius, corners: roundableCorners(for: asset))
        )
    }
}

// MARK: Theming
private extension AssetSelectionView {
    var backgroundColor: Color {
        theme.backgroundColor
    }

    var cellBackgroundColor: Color {
        cellsTheme.backgroundColor
    }

    var listPadding: CGFloat {
        tableTheme.margin
    }

    func cornerRadius(for asset: AppAccountAsset) -> CGFloat {
        cellsTheme.borderRadius > 0 ? cellsTheme.borderRadius : tableTheme.borderRadius
    }

    func roundableCorners(for asset: AssetWrapper) -> UIRectCorner {
        if cellsTheme.borderRadius > 0 {
            return .allCorners
        }

        if viewModel.firstAsset?.assetId == viewModel.lastAsset?.assetId {
            return .allCorners
        }

        if asset.assetId == viewModel.firstAsset?.assetId {
            return [.topLeft, .topRight]
        }

        if asset.assetId == viewModel.lastAsset?.assetId {
            return [.bottomLeft, .bottomRight]
        }

        return []
    }

    func hidingSeparatorEdges(for asset: AppAccountAsset) -> VerticalEdge.Set {
        if viewModel.firstAsset?.assetId == viewModel.lastAsset?.assetId {
            return .all
        }
        if asset.assetId == viewModel.firstAsset?.assetId {
            return .top
        }
        if asset.assetId == viewModel.lastAsset?.assetId {
            return .bottom
        }
        return []
    }
}
