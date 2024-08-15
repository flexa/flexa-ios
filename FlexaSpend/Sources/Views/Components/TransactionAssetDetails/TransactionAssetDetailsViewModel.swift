import Combine
import SwiftUI
import Factory
import FlexaCore

class TransactionAssetDetailsViewModel: ObservableObject {
    typealias Strings = L10n.Payment.Asset.ExchangeRate

    @Injected(\.assetConverterRepository) var assetConverter

    @Published var title: String
    @Published var logoUrl: URL?
    @Published var logoImage: UIImage?
    @Published var gradientColors: [Color]
    @Published var ticker: String
    @Published var secondaryAmount: String
    @Published var mainAmount: String
    @Published var exchangeRate: String
    @Published var networkFee: String
    @Published var baseNetworkFee: String
    @Published var baseNetworkFeeColor: Color?
    @Published var displayMode: DisplayMode
    @Published var isLoading: Bool = false

    var showNetworkFee: Bool {
        !networkFee.isEmpty || isLoading
    }

    var showBadgeNetworkFee: Bool {
        !baseNetworkFee.isEmpty
    }

    var convertedAsset: ConvertedAsset? {
        didSet {
            updateExchangeRateLabels()
        }
    }

    private var decimalAmount: Decimal? {
        mainAmount.digitsAndSeparator?.decimalValue
    }

    private let usdAssetId = "iso4217/USD"

    init(
        displayMode: DisplayMode,
        asset: AssetWrapper,
        secondaryAmount: String = "",
        mainAmount: String = "",
        networkFee: String = "",
        baseNetworkFee: String = "",
        baseNetworkFeeColor: Color? = nil
    ) {
        self.displayMode = displayMode
        self.logoUrl = asset.logoImageUrl
        self.ticker = asset.assetSymbol
        self.gradientColors = []
        self.networkFee = networkFee
        self.baseNetworkFee = baseNetworkFee
        self.baseNetworkFeeColor = baseNetworkFeeColor
        self.logoImage = asset.logoImage

        if let exchange = asset.exchange {
            self.exchangeRate = Strings.value(asset.assetSymbol, exchange.asCurrency)
        } else {
            self.exchangeRate = ""
        }

        switch displayMode {
        case .transaction:
            self.title = L10n.Payment.TransactionDetails.title
            self.mainAmount = mainAmount
            self.secondaryAmount = secondaryAmount
        case .dynamicTransaction:
            self.title = L10n.Payment.TransactionDetails.title
            self.mainAmount = mainAmount
            self.secondaryAmount = ""
            self.networkFee = ""

            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 6

            if let exchange = asset.exchange,
               let decimalAmount,
               let value = formatter.string(for: decimalAmount / exchange) {
                self.secondaryAmount = Strings.amount(value, asset.assetSymbol)
            }

            loadQuote(for: asset, from: usdAssetId, to: asset.assetId)
        case .asset:
            self.title = asset.assetSymbol
            self.mainAmount = asset.valueLabel
            self.secondaryAmount = asset.label
            self.networkFee = ""
        }
    }

    func loadQuote(for asset: AssetWrapper, from fromAsset: String, to toAsset: String) {
        isLoading = true

        Task {
            do {
                let convertedAsset = try await assetConverter.convert(
                    amount: decimalAmount ?? 0,
                    from: fromAsset,
                    to: toAsset
                )

                await MainActor.run {
                    self.convertedAsset = convertedAsset
                    isLoading = false
                }
            } catch let error {
                FlexaLogger.error(error)
                await MainActor.run {
                    isLoading = false
                    networkFee = Strings.cannotLoadNetworkFee
                }
            }
        }
    }

    func updateExchangeRateLabels() {
        guard let convertedAsset else {
            return
        }

        mainAmount = convertedAsset.label
        secondaryAmount = convertedAsset.value.label
        exchangeRate = convertedAsset.value.rate.label
        networkFee = Strings.networkFee(convertedAsset.fee.equivalent)
    }
}

extension TransactionAssetDetailsViewModel {
    enum DisplayMode {
        case asset
        case transaction
        case dynamicTransaction
    }
}
