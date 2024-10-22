import Combine
import SwiftUI
import Factory
import FlexaCore

class TransactionAssetDetailsViewModel: ObservableObject {
    typealias Strings = L10n.Payment.Asset.ExchangeRate

    @Injected(\.exchangeRatesRepository) var exchangeRatesRepository
    @Injected(\.transactionFeesRepository) var transactionFeesRepository
    @Published var title: String
    @Published var gradientColors: [Color]
    @Published var secondaryAmount: String
    @Published var mainAmount: String
    @Published var exchangeRate: String
    @Published var networkFee: String = ""
    @Published var baseNetworkFee: String = ""
    @Published var baseNetworkFeeColor = Color(UIColor.systemGreen)
    @Published var displayMode: DisplayMode
    @Published var isLoading: Bool = false

    var asset: AssetWrapper
    var fee: Fee?

    var showUpdatingBalanceView: Bool = false
    var availableUSDBalance: Decimal

    var showNetworkFee: Bool {
        !networkFee.isEmpty || isLoading
    }

    var showBadgeNetworkFee: Bool {
        !baseNetworkFee.isEmpty
    }

    var logoUrl: URL? {
        asset.logoImageUrl
    }
    var logoImage: UIImage? {
        asset.logoImage
    }

    var ticker: String {
        asset.assetSymbol
    }

    var hasTransactionFee: Bool {
        fee != nil
    }

    var amountWithDiscount: String {
        guard let result = decimalAmountWithDiscount else {
            return ""
        }

        if result == 0 {
            return Strings.free
        }
        return result.asCurrency
    }

    var hasDiscount: Bool {
        discount != nil
    }

    private var decimalAmountWithDiscount: Decimal? {
        guard let value = decimalAmount, let discount else {
            return decimalAmount
        }
        return value - discount
    }

    private var decimalAmount: Decimal? {
        mainAmount.digitsAndSeparator?.decimalValue
    }

    private var discount: Decimal?

    private var feeDecimalAmount: Decimal? {
        fee?.amount.digitsAndSeparator?.decimalValue
    }

    private var transactionExchangeRate: ExchangeRate? {
        guard let fee else {
            return nil
        }

        return exchangeRatesRepository.find(by: fee.asset, unitOfAccount: FlexaConstants.usdAssetId)
    }

    private let usdAssetId = FlexaConstants.usdAssetId

    init(
        displayMode: DisplayMode,
        asset: AssetWrapper,
        secondaryAmount: String = "",
        mainAmount: String = "",
        discount: Decimal? = nil,
        fee: Fee? = nil
    ) {
        self.displayMode = displayMode
        self.gradientColors = []
        self.availableUSDBalance = asset.availableBalanceInLocalCurrency ?? 0
        self.asset = asset
        self.fee = fee
        self.discount = discount

        if let exchange = asset.exchange {
            self.exchangeRate = Strings.value(asset.assetSymbol, exchange.asCurrency)
        } else {
            self.exchangeRate = ""
        }

        switch displayMode {
        case .transaction:
            self.title = L10n.Payment.TransactionDetails.title
            self.mainAmount = mainAmount
            self.secondaryAmount = ""
            self.networkFee = ""
            updateExchangeRateLabels()
            updateNetworkFeeLabels()
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
            updateExchangeRateLabels()
            updateNetworkFeeLabels()
            self.showUpdatingBalanceView = asset.isUpdatingBalance
        }
    }

    func loadExchangeRate() {
        isLoading = true

        Task {
            do {
                var fee = self.fee
                if fee == nil && displayMode == .asset {
                    fee = try await transactionFeesRepository.get(asset: asset.assetId)
                }
                try await exchangeRatesRepository.refresh()
                await handleAsyncUpdates(fee: fee)
            } catch let error {
                await handleAsyncUpdates(error: error)
            }
        }
    }

    func updateExchangeRateLabels() {
        let maximumFractionDigits = asset.exchangeRate?.precision ?? 6
        if let exchange = asset.exchange,
           let value = decimalAmountWithDiscount {
            let value = (value / exchange).formatted(maximumFractionDigits: maximumFractionDigits)
            secondaryAmount = Strings.amount(value, asset.assetSymbol)
            exchangeRate = Strings.value(asset.assetSymbol, asset.exchangeRate?.label ?? exchange.asCurrency)
        }
    }

    func updateNetworkFeeLabels() {
        guard let exchange = transactionExchangeRate?.decimalPrice, let feeDecimalAmount else {
            networkFee = displayMode == .asset ? Strings.cannotLoadNetworkFee : ""
            return
        }
        networkFee = Strings.networkFee((feeDecimalAmount * exchange).asCurrency)
        baseNetworkFee = fee?.price?.label ?? ""
    }

    @MainActor
    func handleAsyncUpdates(fee: Fee? = nil, error: Error? = nil) {
        if let error {
            FlexaLogger.error(error)
            networkFee = Strings.cannotLoadNetworkFee
        } else {
            self.fee = fee
            updateExchangeRateLabels()
            updateNetworkFeeLabels()
        }

        isLoading = false
    }
}

extension TransactionAssetDetailsViewModel {
    enum DisplayMode {
        case asset
        case transaction
    }
}
