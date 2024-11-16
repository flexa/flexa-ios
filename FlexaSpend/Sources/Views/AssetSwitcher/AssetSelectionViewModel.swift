import Foundation
import SwiftUI
import Factory

class AssetSelectionViewModel: ObservableObject, Identifiable {
    @Published var assetAccounts: [AssetAccount] = []
    @Published var hideShortBalances: Bool = false
    @Published var amount: Decimal = 0
    @Published var networkFeeLabel = ""
    @Published var selectedAsset: AssetWrapper?
    @Published var account: Account?

    @Injected(\.flexaClient) var flexaClient
    @Injected(\.accountRepository) var accountRepository

    var hasAmount = false
    var firstAsset: AssetWrapper? {
        assetAccounts.first?.assets.first
    }

    var lastAsset: AssetWrapper? {
        assetAccounts.last?.assets.last
    }

    var showSelectedAssetDetail: Bool = false

    var hasAccountBalance: Bool {
        guard let account else {
            return false
        }
        return account.hasBalance
    }

    var sectionHeaderTitle: String {
        guard amount > 0 else {
            return ""
        }
        return L10n.AccountBalance.PayRemaining.title(remainingBalance.asCurrency).uppercased()
    }

    var accountBalanceTitle: String {
        L10n.AccountBalance.title(account?.balance?.label ?? account?.balance?.amount?.asCurrency ?? "")
    }

    var accountBalanceSubtitle: String {
        if accountBalanceCoversFullAmount {
            return L10n.AccountBalance.FullAmount.text
        } else if amount > 0 {
            return L10n.AccountBalance.CurrentPayment.text
        }
        return L10n.AccountBalance.NextPayment.text
    }

    var accountBalance: Decimal {
        account?.balance?.amount?.decimalValue ?? 0
    }

    var accountBalanceCoversFullAmount: Bool {
        hasAccountBalance && (hasAmount || amount > 0) && amount <= accountBalance
    }

    var appliedBalance: Decimal {
        max(accountBalance, accountBalance - amount)
    }

    var remainingBalance: Decimal {
        amount - appliedBalance
    }

    var showShortBalanceToggle: Bool {
        false
    }

    required init(_ assetAccounts: [AssetAccount],
                  _ hideShortBalances: Bool,
                  _ amount: Decimal,
                  _ selectedAsset: AssetWrapper?) {
        self.assetAccounts = assetAccounts
        self.hideShortBalances = hideShortBalances
        self.amount = amount
        self.selectedAsset = selectedAsset
        self.account = accountRepository.account
    }

    func enoughAmount(_ asset: AssetWrapper) -> Bool {
        asset.balanceInLocalCurrency ?? 0 >= amount
    }

    func isAssetSelected(_ asset: AssetWrapper) -> Bool {
        asset == selectedAsset
    }

    func updateSelectedAsset(_ asset: AssetWrapper) {
        selectedAsset = asset
    }

    func isRowEnabled(_ asset: AssetWrapper) -> Bool {
        true
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
