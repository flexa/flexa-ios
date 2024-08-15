//
//  TransactionAmountView+ViewModel.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 7/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

extension TransactionAmountView.ViewModel {
    enum KeyType: RawRepresentable {
        case digit(String)
        case delete

        var rawValue: String {
            switch self {
            case .digit(let string):
                return string.digitsAndSeparator ?? ""
            default:
                return ""
            }
        }

        init?(rawValue: String) {
            if let digit = rawValue.digitsAndSeparator, !digit.isEmpty {
                self = .digit(rawValue)
            } else {
                self = .delete
            }
        }
    }
}

extension TransactionAmountView {
    class ViewModel: ObservableObject {
        typealias Strings = L10n.LegacyFlexcode.AmountEntry

        @Published var isLoading = false
        @Published var amountText = "$0"
        @Published var error: Error?
        @Published var commerceSessionCreated = false
        @Published var showConfirmationButtonTitle = false
        @Published var showAmountMessage = false

        @Published var selectedAsset: AssetWrapper? {
            didSet {
                guard let selectedAsset else {
                    return
                }
                assetConfig.selectedAppAccountId = selectedAsset.accountId
                assetConfig.selectedAssetId = selectedAsset.assetId
            }
        }

        @Injected(\.commerceSessionRepository) var commerceSessionRepository
        @Injected(\.assetConfig) var assetConfig

        let usdAssetId = "iso4217/USD"
        let locale = Locale(identifier: "en-US")

        var commerceSession: CommerceSession?
        var brand: Brand?

        var brandLogoUrl: URL? {
            brand?.logoUrl
        }

        var decimalSeparator: Character {
            locale.decimalSeparator?.first ?? "."
        }

        var amount: BrandLegacyFlexcodeAmount? {
            brand?.legacyFlexcodes?.first(where: { $0.asset == usdAssetId })?.amount
        }

        var minimumAmount: Decimal {
            amount?.min?.decimalValue ?? Decimal.leastFiniteMagnitude
        }

        var maximumAmount: Decimal {
            amount?.max?.decimalValue ?? Decimal.greatestFiniteMagnitude
        }

        var leftAmountText: String {
            guard let amount = amountText.decimalValue, amount > 0 else {
                return amountText.contains(decimalSeparator) ? "$0." : ""
            }

            let split = amountText.split(separator: decimalSeparator)

            var text = "$0"
            if !amountText.starts(with: String(decimalSeparator)) {
                text = String(split.first ?? "")
                    .decimalValue?
                    .asCurrency(usesGroupingSeparator: false,
                                minimumFractionDigits: 0,
                                maximumFractionDigits: 0) ?? "0"
            }

            if amountText.contains(decimalSeparator) {
                text += String(decimalSeparator)
            }

            if split.count > 1 {
                text += String(split[1])
            }

            return text
        }

        var rightAmountText: String {
            guard !leftAmountText.isEmpty else {
                return "$0"
            }

            guard leftAmountText.contains(decimalSeparator) else {
                return ""
            }

            let split = leftAmountText.split(separator: decimalSeparator)

            guard split.count > 1 else {
                return "00"
            }

            guard String(String(split[1]).suffix(2)).count < 2 else {
                return ""
            }

            return "0"
        }

        var payButtonTitle: String {
            if isLoading {
                return ""
            }

            if !showConfirmationButtonTitle {
                return Strings.Buttons.EnterAmount.title
            }

            return Strings.Buttons.PayNow.title
        }

        var hasAmount: Bool {
            amountText.decimalValue ?? 0 > 0
        }

        var isAmountHigherThanMin: Bool {
            (amountText.decimalValue ?? 0) >= minimumAmount
        }

       @Published var showMinimumAmountMessage = false {
            didSet {
                showAmountMessage = showMinimumAmountMessage || showMaximumAmountMessage
            }
        }
        @Published var showMaximumAmountMessage = false {
            didSet {
                showAmountMessage = showMinimumAmountMessage || showMaximumAmountMessage
            }
        }

        var minimumAmountMessage: String {
            Strings.Labels.minimumAmount(amount?.min?.digitsAndSeparator?.asCurrency ?? "")
        }

        var maximumAmountMessage: String {
            Strings.Labels.maximumAmount(amount?.max?.digitsAndSeparator?.asCurrency ?? "")
        }

        var paymentButtonEnabled: Bool {
            guard !isLoading,
                  hasAmount,
                  let amount = amountText.decimalValue,
                  let balance = selectedAsset?.asset.assetValue.label.decimalValue else {
                return false
            }
            return balance >= amount && amount >= minimumAmount
        }

        init(brand: Brand?) {
            self.brand = brand
        }

        func clear() {
            amountText = "$0"
            isLoading = false
            commerceSession = nil
            commerceSessionCreated = false
            showMaximumAmountMessage = false
            showMinimumAmountMessage = false
            selectedAsset = AssetWrapper(
                appAccountId: assetConfig.selectedAppAccountId,
                assetId: assetConfig.selectedAssetId)
        }

        func keyPressed(_ key: KeyType) {
            var amount = amountText.digitsAndSeparator ?? ""
            switch key {
            case .digit(let digit):
                let split = amount.split(separator: decimalSeparator)

                if digit == String(decimalSeparator) && split.count < 2 ||
                    split.count < 2 && amount.count < 6 ||
                    split.count > 1 && String(split[1]).count < 2 ||
                    split.count == 1 && amount.contains(decimalSeparator) {
                    amount += digit
                }
            case .delete:
                if !amount.isEmpty {
                    amount = String(amount.dropLast())
                }
            }

            if let value = amount.decimalValue, value > maximumAmount {
                guard !showMaximumAmountMessage else {
                    return
                }
                showMaximumAmountMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.showMaximumAmountMessage = false
                }
                return
            }

            amountText = amount.digitsAndSeparator ?? ""

            if isAmountHigherThanMin {
                showMinimumAmountMessage = false
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showMaximumAmountMessage = false
                    self.showMinimumAmountMessage = !self.isAmountHigherThanMin
                }
            }
            showConfirmationButtonTitle = hasAmount && isAmountHigherThanMin
        }

        func createCommerceSession() {
            guard let brand, !isLoading else {
                return
            }
            isLoading = true
            Task {
                do {
                    let commerceSession = try await commerceSessionRepository.create(
                        brand: brand,
                        amount: amountText.decimalValue ?? 0,
                        assetId: usdAssetId,
                        paymentAssetId: assetConfig.selectedAssetId)

                    await handleCommerceSessionCreation(commerceSession: commerceSession)
                } catch let error {
                    FlexaLogger.error(error)
                    await handleCommerceSessionCreation(error: error)
                }
            }
        }

        @MainActor
        func handleCommerceSessionCreation(commerceSession: CommerceSession? = nil, error: Error? = nil) {
            self.commerceSession = commerceSession
            self.commerceSessionCreated = commerceSession != nil
            self.isLoading = error == nil
            self.error = error
        }
    }
}
