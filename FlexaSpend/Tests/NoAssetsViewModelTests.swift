//
//  NoAssetsViewModelTests.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 9/5/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import Nimble
import Quick
import Fakery
import FlexaCore
import Factory
import Foundation
@testable import FlexaSpend

// swiftlint:disable line_length
class NoAssetsViewModelSpec: QuickSpec {
    override class func spec() {
        describe("description") {
            context("0 invalid assets") {
                let viewModel = NoAssetsView.ViewModel([])
                let expectedValue = "There are no assets in your wallet"

                it("returns \"\(expectedValue)\"") {
                    expect(viewModel.description).to(equal(expectedValue))
                }
            }

            context("1 invalid asset") {
                let viewModel = NoAssetsView.ViewModel([
                    FXAvailableAsset(assetId: "BTC", symbol: "BTC", balance: 0.1)
                ])
                let expectedValue = "Flexa doesn’t currently support BTC."

                it("returns \"\(expectedValue)\"") {
                    expect(viewModel.description).to(equal(expectedValue))
                }
            }

            context("2 invalid assets") {
                let viewModel = NoAssetsView.ViewModel([
                    FXAvailableAsset(assetId: "BTC", symbol: "BTC", balance: 0.1),
                    FXAvailableAsset(assetId: "ETH", symbol: "ETH", balance: 1.0)
                ])
                let expectedValue = "Flexa doesn’t currently support BTC or ETH."

                it("returns \"\(expectedValue)\"") {
                    expect(viewModel.description).to(equal(expectedValue))
                }
            }

            context("3 or more invalid assets") {
                let viewModel = NoAssetsView.ViewModel([
                    FXAvailableAsset(assetId: "BTC", symbol: "BTC", balance: 0.1),
                    FXAvailableAsset(assetId: "ETH", symbol: "ETH", balance: 1.0),
                    FXAvailableAsset(assetId: "SOL", symbol: "SOL", balance: 1.0),
                    FXAvailableAsset(assetId: "BAT", symbol: "BAT", balance: 1.0)
                ])
                let expectedValue = "Flexa doesn’t currently support BTC, ETH, or any of the other assets in your wallet."

                it("returns \"\(expectedValue)\"") {
                    expect(viewModel.description).to(equal(expectedValue))
                }
            }
        }
    }
}
// swiftlint:enable line_length
