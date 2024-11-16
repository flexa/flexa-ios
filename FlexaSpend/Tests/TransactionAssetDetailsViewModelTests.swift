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
                    expect(viewModel.mainAmount).to(equal(
                    "\(try XCTUnwrap(asset.balanceInLocalCurrency).asCurrency) available"))
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

                it("does not show the badge network fee when it is not empty") {
                    expect(viewModel.showBadgeNetworkFee).to(beFalse())
                }
            }

            context("when initialized for a transaction") {
                var viewModel: TransactionAssetDetailsViewModel!
                var asset: AssetWrapper!

                let amount = "$5,000.00"
                let baseAmount = "$3,000.00"

                beforeEach {
                    asset = createAssetWrapper()
                    viewModel = TransactionAssetDetailsViewModel(
                        displayMode: .transaction,
                        asset: asset,
                        secondaryAmount: amount,
                        mainAmount: baseAmount
                    )
                }

                it("correctly sets the displayMode") {
                    expect(viewModel.displayMode).to(equal(TransactionAssetDetailsViewModel.DisplayMode.transaction))
                }

                it("sets the title to Details") {
                    expect(viewModel.title).to(equal("Details"))
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
            }
        }
    }

    static func createAssetWrapper() -> AssetWrapper {
        AssetWrapper(accountHash: "wallet", assetId: "SOL")
    }
}

private struct TestAssetHelper: AssetHelperProtocol {
    var symbol: String
    var displayName: String
    var logoImageUrl: URL?
    var logoImage: UIImage?

    static let balance: Decimal = 0.398691
    static let exchangeRate: Decimal = 2
    static let balanceInLocalCurrency: Decimal = balance * exchangeRate

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

    func color(for asset: AssetWrapper) -> Color? {
        .purple
    }

    func fxAccount(for: AssetWrapper) -> FXAssetAccount? {
        nil
    }

    func fxAsset(_ asset: AssetWrapper) -> FXAvailableAsset? {
        FXAvailableAsset(assetId: "SOL", symbol: "SOL", balance: Self.balance, icon: UIImage())
    }

    func exchangeRate(_ asset: AssetWrapper) -> FlexaCore.ExchangeRate? {
        nil
    }

    func oneTimeKey(for asset: AssetWrapper) -> (any FlexaCore.OneTimeKey)? {
        nil
    }

    func balanceInLocalCurrency(_ asset: AssetWrapper) -> Decimal {
        Self.balanceInLocalCurrency
    }

    func availableBalanceInLocalCurrency(_ asset: AssetWrapper) -> Decimal? {
        nil
    }
}
