import Foundation
import SwiftUI
import Factory

class AssetSelectionViewModel: ObservableObject, Identifiable {
    @Published var assetAccounts: [AssetAccount] = []
    @Published var hideShortBalances: Bool = false
    @Published var amount: Decimal = 0
    @Published var networkFeeLabel = ""
    @Published var selectedAsset: AssetWrapper?
    @Injected(\.flexaClient) var flexaClient

    var firstAsset: AssetWrapper? {
        assetAccounts.first?.assets.first
    }

    var lastAsset: AssetWrapper? {
        assetAccounts.last?.assets.last
    }

    var showSelectedAssetDetail: Bool = false

    required init(_ assetAccounts: [AssetAccount],
                  _ hideShortBalances: Bool,
                  _ amount: Decimal,
                  _ selectedAsset: AssetWrapper?) {
        self.assetAccounts = assetAccounts
        self.hideShortBalances = hideShortBalances
        self.amount = amount
        self.selectedAsset = selectedAsset
    }

    func enoughAmount(_ asset: AssetWrapper) -> Bool {
        asset.balance >= amount
    }

    func enoughAmount(for asset: AssetWrapper) -> Bool {
        asset.balance >= amount
    }

    func isAssetSelected(_ asset: AssetWrapper) -> Bool {
        asset == selectedAsset
    }

    func updateSelectedAsset(_ asset: AssetWrapper) {
        selectedAsset = asset
    }
}
