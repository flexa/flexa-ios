import Combine
import SwiftUI
import Factory
import FlexaCore

class TransactionAssetDetailsViewModel: ObservableObject {
    typealias Strings = L10n.Payment.Asset.ExchangeRate

    @Injected(\.exchangeRatesRepository) var exchangeRatesRepository
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

    var asset: AssetWrapper

    var showUpdatingBalanceView: Bool = false
    var availableUSDBalance: Decimal

    var showNetworkFee: Bool {
        !networkFee.isEmpty || isLoading
    }

    var showBadgeNetworkFee: Bool {
        !baseNetworkFee.isEmpty
    }

    private var decimalAmount: Decimal? {
        mainAmount.digitsAndSeparator?.decimalValue
    }

    private let usdAssetId = FlexaConstants.usdAssetId

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
        self.availableUSDBalance = asset.availableBalanceInLocalCurrency ?? 0
        self.asset = asset

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
            updateExchangeRateLabels(asset)
        case .asset:
            self.title = asset.assetSymbol
            if let balance = asset.balanceInLocalCurrency?.asCurrency {
                if asset.isUpdatingBalance {
                    self.mainAmount = L10n.Payment.Balance.title(balance).lowercased()
                } else {
                    self.mainAmount = L10n.Payment.CurrencyAvaliable.title(balance)
                        .lowercased()
                }
            } else {
                self.mainAmount = ""
            }
            self.secondaryAmount = ""
            self.networkFee = ""
            updateExchangeRateLabels(asset)
            self.showUpdatingBalanceView = asset.isUpdatingBalance
        }
    }

    func loadExchangeRate() {
        isLoading = true

        Task {
            do {
                try await exchangeRatesRepository.get(asset: asset.assetId, unitOfAccount: usdAssetId)
                await MainActor.run {
                    updateExchangeRateLabels(asset)
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

    func updateExchangeRateLabels(_ asset: AssetWrapper) {
        let maximumFractionDigits = asset.exchangeRate?.precision ?? 6
        if let exchange = asset.exchange,
           let decimalAmount {
            let value = (decimalAmount / exchange).formatted(maximumFractionDigits: maximumFractionDigits)
            secondaryAmount = Strings.amount(value, asset.assetSymbol)
            exchangeRate = Strings.value(asset.assetSymbol, asset.exchangeRate?.label ?? exchange.asCurrency)
            networkFee = Strings.cannotLoadNetworkFee
        }
    }
}

extension TransactionAssetDetailsViewModel {
    enum DisplayMode {
        case asset
        case transaction
        case dynamicTransaction
    }
}
