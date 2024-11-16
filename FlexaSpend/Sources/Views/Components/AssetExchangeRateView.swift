import SwiftUI
import FlexaUICore

public struct AssetExchangeRateView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Binding var showAssetsModal: Bool
    var title: String
    var url: URL?
    var gradientColors: [Color]

    // Variables created from comments
    var ticker: String = ""
    var availableAmount: String = ""
    var amount: String = ""
    var exchangeRate: String = ""
    var networkFees: String = L10n.Payment.Asset.ExchangeRate.noNetworkFee

    var backgroundColor: Color {
        Color(colorScheme == .dark ? .systemBackground : .secondarySystemBackground)
    }

    public init(showAssetsModal: Binding<Bool>,
                title: String,
                url: URL?,
                gradientColors: [Color],
                ticker: String,
                price: String,
                amount: String,
                exchangeRate: String) {
        _showAssetsModal = showAssetsModal
        self.title = title
        self.url = url
        self.gradientColors = gradientColors
        self.availableAmount = L10n.Payment.Asset.ExchangeRate.avaliable(price)
        self.amount = L10n.Payment.Asset.ExchangeRate.amount(amount, ticker)
        self.exchangeRate = L10n.Payment.Asset.ExchangeRate.value(ticker, exchangeRate)
    }

    public var body: some View {
        VStack {
            List {
                Section(
                    footer: HStack {
                        Text(.init(L10n.Payment.TransactionDetails.footer))
                            .tint(.purple)
                    }
                ) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(availableAmount)
                                .multilineTextAlignment(.leading)
                                .font(.title2.weight(.bold))
                                .foregroundColor(.primary)
                            Text(amount)
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        SpendCircleImage(
                            url,
                            size: .circleImageSize,
                            gradientColors: gradientColors,
                            placeholderColor: .clear
                        )
                    }
                    VStack(alignment: .leading) {
                        HStack(spacing: .hStackSpacing) {
                            Image(systemName: "arrow.left.arrow.right")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.secondary)
                                .frame(width: .imageWidth, height: .imageHeight, alignment: .center)
                            Text(exchangeRate)
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        HStack(spacing: .hStackSpacing) {
                            Image(systemName: "network")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.secondary)
                                .frame(width: .imageWidth, height: .imageHeight, alignment: .center)
                            Text(networkFees)
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.top, -24)
        .background(backgroundColor)
        .navigationBarTitle(title, displayMode: .inline)
        .navigationBarItems(
            trailing:
            Button(action: {
                showAssetsModal = false
            }, label: {
                Text(L10n.Payment.done)
                    .foregroundColor(.purple)
            })
        )
    }
}

private extension CGFloat {
    static let hStackSpacing: CGFloat = 13
    static let imageWidth: CGFloat = 15
    static let imageHeight: CGFloat = 15
    static let circleImageSize: CGFloat = 42
}
