import Foundation
import SwiftUI
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
                balanceView
                if !viewModel.accountBalanceCoversFullAmount {
                    assetsList
                }
            }.listStyle(PlainListStyle())
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
                viewModel.loadAccount()
                if let asset = viewModel.selectedAsset, viewModel.showSelectedAssetDetail {
                    showAssetInfo(asset, standAlone: true)
                    viewModel.showSelectedAssetDetail = false
                }
            }
    }

    @ViewBuilder
    private var assetsList: some View {
        Section(
            header: sectionHeader
        ) {
            ForEach($viewModel.assetAccounts, id: \.id) { account in
                ForEach(account.assets, id: \.id) { asset in
                    if !viewModel.enoughAmount( asset.wrappedValue) && viewModel.hideShortBalances {
                        EmptyView()
                    } else {
                        assetRow(asset.wrappedValue)
                            .listRowSeparator(.hidden, edges: hidingSeparatorEdges(for: asset.wrappedValue))
                            .listRowSeparatorTint(tableTheme.separator.color)
                    }
                }
            }
            if viewModel.showShortBalanceToggle {
                Toggle(CoreStrings.Payment.HideShortBalances.title, isOn: $viewModel.hideShortBalances)
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(Color.primary)
                    .toggleStyle(SwitchToggleStyle(tint: Color.gray))
                    .padding(.bottom, 10)
            }
        }
    }

    @ViewBuilder
    private var balanceView: some View {
        if viewModel.hasAccountBalance {
            Section {
                FlexaBalanceView(
                    iconAlignment: viewModel.accountBalanceCoversFullAmount ? .top : .left,
                    title: viewModel.accountBalanceTitle,
                    subtitle: viewModel.accountBalanceSubtitle
                )
            }.listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
        }
    }

    @ViewBuilder
    private var sectionHeader: some View {
        if viewModel.hasAccountBalance {
            Text(viewModel.sectionHeaderTitle)
                .fontWeight(.regular)
                .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 0))
        }

    }

    func showAssetInfo(_ asset: AssetWrapper, standAlone: Bool = false) {
        transactionAssetDetailsView = TransactionAssetDetailsView(
            showView: $showAssetsModal,
            tintColor: asset.assetColor ?? .purple,
            viewModel: TransactionAssetDetailsViewModel(
                displayMode: .asset,
                asset: asset,
                isStandAlone: standAlone,
                hasAmount: viewModel.hasAmount
            )
        )

        if viewModel.showSelectedAssetDetail {
            var transaction = SwiftUICore.Transaction()
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
            if viewModel.isRowEnabled(asset) {
                showAssetsModal = false
                viewModel.updateSelectedAsset(asset)
                if let selectedAsset = viewModel.selectedAsset {
                    didSelect?(selectedAsset)
                }
            }
        } label: {
            AssetRow(asset: asset,
                     selected: viewModel.isAssetSelected(asset),
                     enable: viewModel.isRowEnabled(asset),
                     showInfo: {
                showAssetInfo(asset)
            })
        }.listRowBackground(
            Rectangle()
                .fill(cellBackgroundColor)
                .cornerRadius(cornerRadius(for: asset), corners: roundableCorners(for: asset))
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

    func cornerRadius(for asset: AssetWrapper) -> CGFloat {
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

    func hidingSeparatorEdges(for asset: AssetWrapper) -> VerticalEdge.Set {
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
