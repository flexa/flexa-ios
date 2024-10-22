import SwiftUI
import FlexaUICore

struct TransactionAssetDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Binding var showView: Bool

    @ObservedObject var viewModel: TransactionAssetDetailsViewModel

    var backgroundColor: Color {
        Color(colorScheme == .dark ? .systemBackground : .secondarySystemBackground)
    }

    var tintColor: Color

    init(showView: Binding<Bool>,
         tintColor: Color = .purple,
         viewModel: TransactionAssetDetailsViewModel) {
        _showView = showView
        self.viewModel = viewModel
        self.tintColor = tintColor
    }

    var body: some View {
        detailsView
            .onAppear {
                viewModel.loadExchangeRate()
            }
        .navigationBarItems(
            leading: viewModel.displayMode == .transaction ? leftHeaderView : nil,
            trailing: rightHeaderView
        )
    }
}

private extension TransactionAssetDetailsView {
    @ViewBuilder
    var leftHeaderView: some View {
        FlexaRoundedButton(
            .settings,
            symbolFont: .system(size: 13, weight: .bold),
            size: CGSize(width: 26, height: 26))
    }

    @ViewBuilder
    var footerView: some View {
        Text(.init(L10n.Payment.TransactionDetails.footer))
            .tint(.purple)
    }

    @ViewBuilder
    var headerView: some View {
        if viewModel.showUpdatingBalanceView {
            UpdatingBalanceView(
                backgroundColor: Color(UIColor.quaternarySystemFill), amount: viewModel.availableUSDBalance
            )
        }
    }

    @ViewBuilder
    var rightHeaderView: some View {
        Button(action: {
            showView = false
        }, label: {
            switch viewModel.displayMode {
            case .asset:
                Text(L10n.Payment.done)
                    .font(.body.weight(.semibold))
            case .transaction:
                Text(L10n.Payment.done)
                    .font(.body.weight(.semibold))
                    .foregroundColor(tintColor)
            }
        }).padding(.trailing, 4)
    }

    @ViewBuilder
    var detailsView: some View {
        List {
            Section(
                header: headerView,
                footer: footerView
            ) {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            if viewModel.hasDiscount {
                                Text(viewModel.mainAmount)
                                    .foregroundColor(.secondary)
                                    .strikethrough(color: .secondary)
                            }
                            Text(viewModel.hasDiscount ? viewModel.amountWithDiscount : viewModel.mainAmount)
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
        .padding(.top, -24)
        .animation(.none)
        .background(backgroundColor)
        .navigationBarTitle(viewModel.title, displayMode: .inline)
    }
}

private extension CGFloat {
    static let hStackSpacing: CGFloat = 13
    static let imageWidth: CGFloat = 15
    static let imageHeight: CGFloat = 15
    static let circleImageSize: CGFloat = 42
}
