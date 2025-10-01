import SwiftUI
import FlexaUICore

public struct TransactionAssetDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.theme.tables) var tablesTheme
    @Binding var showView: Bool
    @ObservedObject public var viewModel: TransactionAssetDetailsViewModel

    var backgroundColor: Color {
        Color(colorScheme == .dark ? .systemBackground : .secondarySystemBackground)
    }

    public var tintColor: Color

    public init(showView: Binding<Bool>,
                tintColor: Color = .flexaTintColor,
                viewModel: TransactionAssetDetailsViewModel) {
        _showView = showView
        self.viewModel = viewModel
        self.tintColor = tintColor
    }

    public var body: some View {
        if #available(iOS 26.0, *) {
            contentView
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                            FlexaRoundedButton(.checkmark) {
                                showView = false
                            }.tint(tintColor)
                    }
                }
        } else {
            contentView
                .navigationBarItems(
                    leading: leftHeaderView,
                    trailing: rightHeaderView
                )
                .navigationBarBackButtonHidden(true)
        }
    }
}

private extension TransactionAssetDetailsView {
    private var contentView: some View {
        detailsView
            .onAppear {
                viewModel.loadExchangeRate()
                viewModel.loadAccount()
            }
    }

    @ViewBuilder
    var leftHeaderView: some View {
        if viewModel.displayMode == .asset && !viewModel.isStandAlone {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.backward")
                        .font(.body.bold())
                    Text(CoreStrings.Payment.PayUsing.title)
                }.foregroundColor(tintColor)
            }.offset(x: -8)
        }
    }

    @ViewBuilder
    var footerView: some View {
        Text(.init(CoreStrings.Payment.TransactionDetails.footer))
            .tint(tintColor)
    }

    @ViewBuilder
    var headerView: some View {
        if viewModel.accountBalanceCoversFullAmount {
            Section {
                FlexaBalanceView(
                    iconAlignment: .top,
                    title: viewModel.accountBalanceTitle,
                    subtitle: viewModel.accountBalanceSubtitle
                )
            }.listRowBackground(
                Rectangle()
                    .fill(Color(UIColor.quaternarySystemFill))
                    .cornerRadius(cornerRadius, corners: .allCorners)
                )
        } else if viewModel.showUpdatingBalanceView || viewModel.hasAccountBalance {
            Section {
                VStack(alignment: .leading) {
                    if viewModel.showUpdatingBalanceView {
                        UpdatingBalanceView(
                            backgroundColor: .clear,
                            amount: viewModel.availableUSDBalance,
                            horizontalPadding: 0,
                            verticalPadding: 0
                        )
                    }

                    if viewModel.showUpdatingBalanceView && viewModel.hasAccountBalance {
                        Divider()
                            .padding(.bottom, 10)
                            .padding(.horizontal, 8)
                    }

                    if viewModel.hasAccountBalance {
                        FlexaBalanceView(
                            iconAlignment: .right,
                            title: viewModel.accountBalanceTitle,
                            subtitle: viewModel.accountBalanceSubtitle
                        )
                        .padding(.leading, 10)
                        .padding(.trailing, 8)
                        .padding(.bottom, viewModel.showUpdatingBalanceView ? 12 : 0)
                    }
                }.listRowBackground(
                    Rectangle()
                        .fill(Color(UIColor.quaternarySystemFill))
                        .cornerRadius(cornerRadius, corners: .allCorners)
                ).listRowInsets(
                    EdgeInsets(top: 16, leading: 12.5, bottom: 16, trailing: 12.5)
                )

            }
        }
    }

    @ViewBuilder
    var rightHeaderView: some View {
        Button(action: {
            showView = false
        }, label: {
            Text(CoreStrings.Payment.done)
                .font(.body.weight(.semibold))
                .foregroundColor(tintColor)

        }).padding(.trailing, 4)
    }

    @ViewBuilder
    var detailsView: some View {
        List {
            if #available(iOS 17.0, *) {
                headerView
                    .listSectionSpacing(14)
            } else {
                headerView
            }
            if !viewModel.accountBalanceCoversFullAmount {
                infoView
            }
        }
        .padding(.top, -30)
        .animation(.none)
        .background(backgroundColor)
        .navigationBarTitle(viewModel.title, displayMode: .inline)
    }

    @ViewBuilder
    var infoView: some View {
        Section(
            footer: footerView
        ) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        if viewModel.displayMode == .transaction && ( viewModel.hasDiscount || viewModel.hasAccountBalance) {
                            Text(viewModel.hasDiscount ? viewModel.transactionAmount.asCurrency : viewModel.mainAmount)
                                .foregroundColor(.secondary)
                                .strikethrough(color: .secondary)
                        }
                        Text(viewModel.hasDiscount ? viewModel.amountWithDiscount : viewModel.transactionAmount.asCurrency)
                    }.multilineTextAlignment(.leading)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(viewModel.secondaryAmount)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                if let image = viewModel.logoImage {
                    SpendCircleImage(
                        Image(uiImage: image),
                        size: .circleImageSize,
                        gradientColors: viewModel.gradientColors
                    )
                } else {
                    SpendCircleImage(
                        viewModel.logoUrl,
                        size: .circleImageSize,
                        gradientColors: viewModel.gradientColors
                    )
                }
            }
            VStack(alignment: .leading) {
                HStack(spacing: .hStackSpacing) {
                    Image(systemName: "arrow.left.arrow.right")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.secondary)
                        .frame(width: .imageWidth, height: .imageHeight, alignment: .center)
                    Text(viewModel.exchangeRate)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(spacing: .hStackSpacing) {
                    if viewModel.showNetworkFee {
                        Image(systemName: "network")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                            .frame(width: .imageWidth, height: .imageHeight, alignment: .center)
                        if viewModel.isLoading && !viewModel.hasTransactionFee {
                            ProgressView()
                        } else {
                            Text(viewModel.networkFee)
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    if viewModel.showBadgeNetworkFee {
                        Text(viewModel.baseNetworkFee)
                            .font(.caption2.weight(.medium))
                            .foregroundColor(viewModel.baseNetworkFeeColor)
                            .padding(EdgeInsets(top: 4, leading: 7, bottom: 4, trailing: 7))
                            .background(viewModel.baseNetworkFeeColor.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
            }
        }
    }
}

private extension CGFloat {
    static let hStackSpacing: CGFloat = 13
    static let imageWidth: CGFloat = 15
    static let imageHeight: CGFloat = 15
    static let circleImageSize: CGFloat = 42
}

private extension TransactionAssetDetailsView {
    var cornerRadius: CGFloat {
        tablesTheme.cell.borderRadius > 0 ? tablesTheme.cell.borderRadius : tablesTheme.borderRadius
    }
}
