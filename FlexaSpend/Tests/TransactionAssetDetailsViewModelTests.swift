import Nimble
import SwiftUI
import Quick
import Fakery
import XCTest
import Factory
import Foundation
import Combine
@testable import FlexaSpend

// swiftlint:disable function_body_length
// swiftlint:disable line_length
class TransactionAssetDetailsViewModelTests: QuickSpec {
    static let testURL = URL(string: Faker().internet.url())

    override class func spec() {
        beforeSuite {
            Container.shared.assetsHelper.register { TestAssetHelper(symbol: "SOL", displayName: "Solana", logoImageUrl: testURL) }
        }

        describe("init") {
            context("when initialized for an asset") {
                var viewModel: TransactionAssetDetailsViewModel!
                var asset: AssetWrapper!
                beforeEach {
                    asset = createAssetWrapper()
                    viewModel = TransactionAssetDetailsViewModel(
                        displayMode: .asset,
                        asset: asset
                    )
                }

                it("correctly sets the displayMode") {
                    expect(viewModel.displayMode).to(equal(TransactionAssetDetailsViewModel.DisplayMode.asset))
                }

                it("sets the title to the ticker of the asset") {
                    expect(viewModel.title).to(equal(asset.assetSymbol))
                }

                it("sets the amount to the assets value's label") {
                    expect(viewModel.mainAmount).to(equal(asset.valueLabel))
                }

                it("correctly sets the exchange rate") {
                    // swiftlint:disable:next force_unwrapping
                    let expectedExchangeRate = "1 \(asset.assetSymbol) = \(asset.exchange!.asCurrency)"
                    expect(viewModel.exchangeRate).to(equal(expectedExchangeRate))
                }

                it("correctly sets the URL") {
                    expect(viewModel.logoUrl).to(equal(testURL))
                }

                it("correctly sets the gradient colors") {
                    expect(viewModel.gradientColors).to(equal(asset.gradientColors))
                }

                it("correctly sets the ticker") {
                    expect(viewModel.ticker).to(equal(asset.assetSymbol))
                }

                it("does not show the network fee when it is not empty") {
                    expect(viewModel.showNetworkFee).to(beFalse())
                }

                it("does not show the badge network fee when it is not empty") {
                    expect(viewModel.showBadgeNetworkFee).to(beFalse())
                }
            }

            context("when initialized for a transaction") {
                var viewModel: TransactionAssetDetailsViewModel!
                var asset: AssetWrapper!

                let amount = "$5,000.00"
                let baseAmount = "$3,000.00"
                let networkFee = "0.01 SOL"
                let baseNetworkFee = "$0,25"

                beforeEach {
                    asset = createAssetWrapper()
                    viewModel = TransactionAssetDetailsViewModel(
                        displayMode: .transaction,
                        asset: asset,
                        secondaryAmount: amount,
                        mainAmount: baseAmount,
                        networkFee: networkFee,
                        baseNetworkFee: baseNetworkFee
                    )
                }

                it("correctly sets the displayMode") {
                    expect(viewModel.displayMode).to(equal(TransactionAssetDetailsViewModel.DisplayMode.transaction))
                }

                it("sets the title to Details") {
                    expect(viewModel.title).to(equal("Details"))
                }

                it("correctly sets the amount") {
                    expect(viewModel.secondaryAmount).to(equal(amount))
                }

                it("correctly sets the base amount") {
                    expect(viewModel.mainAmount).to(equal("\(baseAmount)"))
                }

                it("correctly sets the exchange rate") {
                    // swiftlint:disable:next force_unwrapping
                    let expectedExchangeRate = "1 \(asset.assetSymbol) = \(asset.exchange!.asCurrency)"
                    expect(viewModel.exchangeRate).to(equal(expectedExchangeRate))
                }

                it("correctly sets the URL") {
                    expect(viewModel.logoUrl).to(equal(testURL))
                }

                it("correctly sets the network fee") {
                    expect(viewModel.networkFee).to(equal(networkFee))
                }

                it("correctly sets the base network fee fee") {
                    expect(viewModel.baseNetworkFee).to(equal(baseNetworkFee))
                }

                it("shows the network fee if it is not empty") {
                    expect(viewModel.showNetworkFee).to(beTrue())
                }

                it("shows the badge network fee when it is empty") {
                    expect(viewModel.showBadgeNetworkFee).to(beTrue())
                }

                it("sets the base network fee to the formatted fee") {
                    expect(viewModel.baseNetworkFee).to(equal(baseNetworkFee))
                }
            }
        }
    }

    static func createAssetWrapper() -> AssetWrapper {
        let availableAsset = TestAvailableAsset(
            assetId: "SOL",
            balance: "0.38691",
            value: TestAvailableAssetValue(
                asset: "iso4217/usd",
                label: "$66.95 available",
                labelTitleCase: "$66.95 Available"
            ),
            label: "0.38691 SOL"
        )

        let appAccount = TestAvailableAppAccount(
            accountId: "6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b",
            assets: [availableAsset])
        return AssetWrapper(appAccount: appAccount, asset: availableAsset)
    }
}

private struct TestAvailableAppAccount: AppAccount {
    var accountId: String
    var assets: [TestAvailableAsset]
    var accountAssets: [FlexaCore.AppAccountAsset] {
        get {
            assets
        }
        set {

        }
    }

}

private struct TestAvailableAsset: AppAccountAsset {
    var assetId: String
    var balance: String
    var label: String
    var value: TestAvailableAssetValue

    var assetValue: FlexaCore.AppAccountAssetValue {
        value
    }

    var assetKey: FlexaCore.AppAccountAssetKey? {
        nil
    }

    init(assetId: String,
         balance: String,
         value: TestAvailableAssetValue,
         label: String
    ) {
        self.assetId = assetId
        self.balance = balance
        self.value = value
        self.label = label
    }
}

private struct TestAvailableAssetValue: AppAccountAssetValue {
    var asset: String
    var label: String
    var labelTitleCase: String
}

private struct TestAssetHelper: AssetHelperProtocol {
    var symbol: String
    var displayName: String
    var logoImageUrl: URL?
    var logoImage: UIImage?

    init(symbol: String, displayName: String, logoImageUrl: URL? = nil, logoImage: UIImage? = nil) {
        self.symbol = symbol
        self.displayName = displayName
        self.logoImageUrl = logoImageUrl
        self.logoImage = logoImage
    }

    func symbol(for: AssetWrapper) -> String {
        symbol
    }

    func displayName(for: AssetWrapper) -> String {
        displayName
    }

    func logoImageUrl(for: AssetWrapper) -> URL? {
        logoImageUrl
    }

    func logoImage(for: AssetWrapper) -> UIImage? {
        logoImage
    }

    func fxAccount(for: AssetWrapper) -> FXAppAccount? {
        nil
    }

    func fxAsset(_ asset: AssetWrapper) -> FXAvailableAsset? {
        nil
    }

    func assetWithKey(for asset: AssetWrapper) -> FlexaCore.AppAccountAsset {
        asset.asset
    }
}
