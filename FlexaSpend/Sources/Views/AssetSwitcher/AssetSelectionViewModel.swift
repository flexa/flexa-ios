import Foundation
import SwiftUI
import Factory

class AssetSelectionViewModel: ObservableObject, Identifiable {
    @Published var appAccounts: [AppAccount] = []
    @Published var hideShortBalances: Bool = false
    @Published var amount: Decimal = 0
    @Published var networkFeeLabel = ""
    @Published var selectedAsset: AssetWrapper?
    @Injected(\.flexaClient) var flexaClient

    var firstAsset: AppAccountAsset? {
        appAccounts.first?.accountAssets.first
    }

    var lastAsset: AppAccountAsset? {
        appAccounts.last?.accountAssets.last
    }

    var showSelectedAssetDetail: Bool = false

    required init(_ appAccounts: [AppAccount],
                  _ hideShortBalances: Bool,
                  _ amount: Decimal,
                  _ selectedAsset: AssetWrapper?) {
        self.appAccounts = appAccounts
        self.hideShortBalances = hideShortBalances
        self.amount = amount
        self.selectedAsset = selectedAsset
    }

    func enoughAmount(_ asset: AssetWrapper) -> Bool {
        asset.decimalBalance >= amount
    }

    func enoughAmount(for asset: AppAccountAsset) -> Bool {
        asset.decimalBalance >= amount
    }

    func isAssetSelected(_ asset: AssetWrapper) -> Bool {
        asset == selectedAsset
    }

    func updateSelectedAsset(_ asset: AssetWrapper) {
        selectedAsset = asset
    }
}
