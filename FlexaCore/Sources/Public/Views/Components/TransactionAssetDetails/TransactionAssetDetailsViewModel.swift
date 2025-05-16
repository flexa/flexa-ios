import Combine
import SwiftUI
import Factory

public class TransactionAssetDetailsViewModel: ObservableObject {
    typealias Strings = CoreStrings.Payment.Asset.ExchangeRate

    @Injected(\.exchangeRatesRepository) var exchangeRatesRepository
    @Injected(\.transactionFeesRepository) var transactionFeesRepository
    @Injected(\.accountRepository) var accountRepository
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
    @Published var account: Account?

    var asset: AssetWrapper
    var fee: Fee?
    var hasAmount: Bool = false
    var showUpdatingBalanceView: Bool = false
    var availableUSDBalance: Decimal
    var isStandAlone: Bool = false

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

    var transactionAmount: Decimal {
        guard displayMode == .transaction else {
            return decimalAmount
        }

        if decimalAmountWithDiscount == 0 {
            return 0
        }
        if hasAccountBalance {
            return decimalAmount - appliedBalance
        }
        return decimalAmount
    }

    var amountWithDiscount: String {
        if decimalAmountWithDiscount == 0 {
            return Strings.free
        }
        return decimalAmountWithDiscount.asCurrency
    }

    var hasDiscount: Bool {
        discount != nil
    }

    var hasAccountBalance: Bool {
        guard let account else {
            return false
        }
        return account.hasBalance
    }

    var accountBalanceTitle: String {
        CoreStrings.AccountBalance.title(account?.balance?.label ?? account?.balance?.amount?.asCurrency ?? "")
    }

    var accountBalanceSubtitle: String {
        if accountBalanceCoversFullAmount {
            return CoreStrings.AccountBalance.FullAmount.text
        } else if hasAmount {
            return CoreStrings.AccountBalance.CurrentPayment.text
        }
        return CoreStrings.AccountBalance.NextPayment.text
    }

    var accountBalance: Decimal {
        account?.balance?.amount?.decimalValue ?? 0
    }

    var accountBalanceCoversFullAmount: Bool {
        displayMode == .transaction &&
        hasAccountBalance &&
        decimalAmountWithDiscount == 0
    }

    private var decimalAmountWithDiscount: Decimal {
        guard displayMode == .transaction else {
            return decimalAmount
        }
        return decimalAmount - (discount ?? 0) - appliedBalance
    }

    private var decimalAmount: Decimal {
        mainAmount.digitsAndSeparator?.decimalValue ?? 0
    }

    private var appliedBalance: Decimal {
        min(decimalAmount - (discount ?? 0), accountBalance)
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
    private let minimumNetworkFee: Decimal = 0.01

    public init(
        displayMode: DisplayMode,
        asset: AssetWrapper,
        secondaryAmount: String = "",
        mainAmount: String = "",
        discount: Decimal? = nil,
        fee: Fee? = nil,
        isStandAlone: Bool = false,
        hasAmount: Bool = false
    ) {
        self.displayMode = displayMode
        self.gradientColors = []
        self.availableUSDBalance = asset.availableBalanceInLocalCurrency ?? 0
        self.asset = asset
        self.fee = fee
        self.discount = discount
        self.isStandAlone = isStandAlone
        self.hasAmount = hasAmount

        if let exchange = asset.exchange {
            self.exchangeRate = Strings.value(asset.assetSymbol, exchange.asCurrency)
        } else {
            self.exchangeRate = ""
        }

        switch displayMode {
        case .transaction:
            self.title = CoreStrings.Payment.TransactionDetails.title
            self.mainAmount = mainAmount
            self.secondaryAmount = ""
            self.networkFee = ""
            self.account = accountRepository.account
            updateExchangeRateLabels()
            updateNetworkFeeLabels()
        case .asset:
            self.title = asset.assetSymbol
            if let balance = asset.balanceInLocalCurrency?.asCurrency {
                if asset.isUpdatingBalance {
                    self.mainAmount = CoreStrings.Payment.Balance.title(balance).lowercased()
                } else {
                    self.mainAmount = CoreStrings.Payment.CurrencyAvaliable.title(balance)
                        .lowercased()
                }
            } else {
                self.mainAmount = ""
            }
            self.secondaryAmount = ""
            self.networkFee = ""
            self.account = accountRepository.account
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
                await handleFeeUpdates(fee: fee)
            } catch let error {
                await handleFeeUpdates(error: error)
            }
        }
    }

    func updateExchangeRateLabels() {
        let maximumFractionDigits = asset.exchangeRate?.precision ?? 6
        if let exchange = asset.exchange {
            let value = (decimalAmountWithDiscount / exchange)
                .rounded(places: maximumFractionDigits)
                .formatted(maximumFractionDigits: maximumFractionDigits)
            secondaryAmount = Strings.amount(value, asset.assetSymbol)
            exchangeRate = Strings.value(asset.assetSymbol, asset.exchangeRate?.label ?? exchange.asCurrency)
        }
    }

    func updateNetworkFeeLabels() {
        guard let exchange = transactionExchangeRate?.decimalPrice, let feeDecimalAmount else {
            networkFee = displayMode == .asset ? Strings.cannotLoadNetworkFee : ""
            return
        }
        let networkFeeValue = feeDecimalAmount * exchange
        if networkFeeValue < minimumNetworkFee {
            networkFee = Strings.lessThanMinNetworkFee(minimumNetworkFee.asCurrency)
        } else {
            networkFee = Strings.networkFee(networkFeeValue.asCurrency)
        }
        baseNetworkFee = fee?.price?.label ?? ""
    }

    @MainActor
    func handleFeeUpdates(fee: Fee? = nil, error: Error? = nil) {
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

    func loadAccount() {
        Task {
            if let account = accountRepository.account {
                await handleAccountUpdate(account)
            }
            do {
                let account = try await accountRepository.getAccount()
                await handleAccountUpdate(account)
            } catch let error {
                FlexaLogger.error(error)
                await handleAccountUpdate(nil)
            }
        }
    }

    @MainActor
    private func handleAccountUpdate(_ account: Account?) {
        self.account = account
    }
}

public extension TransactionAssetDetailsViewModel {
    enum DisplayMode {
        case asset
        case transaction
    }
}
