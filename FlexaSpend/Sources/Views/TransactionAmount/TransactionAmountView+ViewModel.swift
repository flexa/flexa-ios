//
//  TransactionAmountView+ViewModel.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 7/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory
import SwiftUI

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
    typealias Strings = L10n.LegacyFlexcode.AmountEntry

    class ViewModel: ObservableObject {
        @Published var isLoading = false
        @Published var loadingTitle = ""
        @Published var isPaymentDone = false
        @Published var amountText = "$0"
        @Published var error: Error?
        @Published var commerceSessionCreated = false
        @Published var showConfirmationButtonTitle = false
        @Published var showAmountMessage = false
        @Published var account: Account?

        @Published var selectedAsset: AssetWrapper? {
            didSet {
                guard let selectedAsset else {
                    return
                }
                assetConfig.selectedAssetAccountHash = selectedAsset.accountId
                assetConfig.selectedAssetId = selectedAsset.assetId
            }
        }

        @Injected(\.commerceSessionRepository) var commerceSessionRepository
        @Injected(\.assetConfig) var assetConfig
        @Injected(\.accountRepository) var accountRepository
        private var digitsAdded = false

        let usdAssetId = FlexaConstants.usdAssetId
        let locale = Locale(identifier: "en-US")
        var cancelledByUser = false

        var commerceSession: CommerceSession?
        var brand: Brand?

        var fee: Fee? {
            commerceSession?.requestedTransaction?.fee
        }

        var brandLogoUrl: URL? {
            brand?.logoUrl
        }

        var brandColor: Color {
            brand?.color ?? .purple
        }

        var decimalSeparator: Character {
            locale.decimalSeparator?.first ?? "."
        }

        var amountRestrictions: BrandLegacyFlexcodeAmount? {
            brand?.legacyFlexcodes?.first(where: { $0.asset == usdAssetId })?.amount
        }

        var decimalAmount: Decimal {
            amountText.decimalValue ?? 0
        }

        var minimumAmount: Decimal {
            amountRestrictions?.min?.decimalValue ?? Decimal.leastFiniteMagnitude
        }

        var maximumAmount: Decimal {
            amountRestrictions?.max?.decimalValue ?? Decimal.greatestFiniteMagnitude
        }

        var leftAmountText: String {
            guard let amount = amountText.decimalValue, amount > 0 else {
                if amountText.contains(decimalSeparator) {
                    return "$0."
                } else {
                    return digitsAdded ? "$0" : ""
                }
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
            if isPaymentDone {
                return L10n.Common.done
            }

            if isLoading {
                return loadingTitle
            }

            if !showConfirmationButtonTitle {
                return Strings.Buttons.Payment.EnterAmount.title
            }

            if !isBalanceAvailable && !paymentButtonEnabled && !accountBalanceCoversFullAmount {
                return " "
            }

            return Strings.Buttons.Payment.Confirm.title
        }

        var hasAmount: Bool {
            decimalAmount > 0
        }

        var isAmountHigherThanMin: Bool {
            decimalAmount >= minimumAmount
        }

        var availableUSDBalance: Decimal {
            selectedAsset?.availableBalanceInLocalCurrency ?? 0
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
            Strings.Labels.minimumAmount(amountRestrictions?.min?.digitsAndSeparator?.asCurrency ?? "")
        }

        var maximumAmountMessage: String {
            Strings.Labels.maximumAmount(amountRestrictions?.max?.digitsAndSeparator?.asCurrency ?? "")
        }

        var paymentButtonEnabled: Bool {
            guard !isLoading,
                  hasAmount,
                  let amount = amountText.decimalValue,
                  let balance =
                    selectedAsset?.availableBalanceInLocalCurrency ?? selectedAsset?.balanceInLocalCurrency else {
                return false
            }
            return balance + accountBalance >= amount - promotionDiscount && amount >= minimumAmount
        }

        var showNoBalanceButton: Bool {
            !isLoading &&
            !paymentButtonEnabled &&
            !accountBalanceCoversFullAmount &&
            hasAmount &&
            !isBalanceAvailable &&
            showConfirmationButtonTitle
        }

        var isBalanceAvailable: Bool {
            guard let selectedAsset else {
                return true
            }
            return !selectedAsset.isUpdatingBalance
        }

        var promotion: Promotion? {
            applyingPromotion ?? brand?.promotions.first
        }

        var hasPromotion: Bool {
            promotion != nil
        }

        var promotionText: String {
            guard let promotion else {
                return ""
            }

            var label = promotion.label
            if promotionApplies {
                label = L10n.LegacyFlexcode.Promotions.Labels.saving(promotionDiscount.asCurrency)
            }

            guard let url = promotion.url else {
                return label
            }

            return "[\(label)](\(url))"
        }

        var promotionDiscount: Decimal {
            applyingPromotion?.discount(for: decimalAmount) ?? 0
        }

        var promotionApplies: Bool {
            applyingPromotion != nil
        }

        var applyingPromotion: Promotion? {
            guard decimalAmount >= minimumAmount else {
                return nil
            }

            return brand?.promotions.applyingTo(amount: decimalAmount).first
        }

        var hasAccountBalance: Bool {
            guard let account else {
                return false
            }
            return account.hasBalance
        }

        var accountBalance: Decimal {
            account?.balance?.amount?.decimalValue ?? 0
        }

        var accountBalanceCoversFullAmount: Bool {
            hasAmount && hasAccountBalance && accountBalance >= decimalAmount - promotionDiscount
        }

        var assetSwitcherTitle: String {
            if hasAmount && isAmountHigherThanMin && accountBalanceCoversFullAmount {
                return L10n.AssetSwitcher.UsingFlexaAccount.title
            }
            return L10n.Payment.UsingTicker.subtitle(selectedAsset?.assetSymbol ?? "")
        }

        init(brand: Brand?) {
            self.brand = brand
        }

        func clear() {
            cancelledByUser = false
            amountText = "$0"
            isLoading = false
            commerceSession = nil
            loadingTitle = ""
            isPaymentDone = false
            commerceSessionCreated = false
            showMaximumAmountMessage = false
            showMinimumAmountMessage = false
            showConfirmationButtonTitle = false
            selectedAsset = AssetWrapper(
                accountHash: assetConfig.selectedAssetAccountHash,
                assetId: assetConfig.selectedAssetId)
            account = accountRepository.account
        }

        func keyPressed(_ key: KeyType) {
            var amount = amountText.digitsAndSeparator ?? ""
            switch key {
            case .digit(let digit):
                digitsAdded = true
                let split = amount.split(separator: decimalSeparator)

                if digit == String(decimalSeparator) && split.count < 2 ||
                    split.count < 2 && amount.count < 10 ||
                    split.count > 1 && String(split[1]).count < 2 ||
                    split.count == 1 && amount.contains(decimalSeparator) {
                    amount += digit
                }
            case .delete:
                if !amount.isEmpty {
                    amount = String(amount.dropLast())
                }
                showMaximumAmountMessage = false
                digitsAdded = (amount.decimalValue ?? 0) > 0
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
                    self.showMinimumAmountMessage = !self.isAmountHigherThanMin && self.digitsAdded
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

        func setCommerceSession(_ commerceSession: CommerceSession) {
            clear()
            self.commerceSession = commerceSession
            brand = commerceSession.brand
            amountText = commerceSession.amount.asCurrency
        }

        @MainActor
        func handleCommerceSessionCreation(commerceSession: CommerceSession? = nil, error: Error? = nil) {
            commerceSessionRepository.setCurrent(
                commerceSession,
                isLegacy: true,
                wasTransactionSent: commerceSession != nil
            )

            self.commerceSession = commerceSession
            self.commerceSessionCreated = commerceSession != nil
            self.isLoading = error == nil
            self.error = error

            if isLoading {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard let self, self.loadingTitle.isEmpty else {
                        return
                    }
                    setLoadingButtonTitle(L10n.Common.signing)
                }
            }
        }

        func transactionSent() {
            Task {
                await setLoadingButtonTitle(L10n.Common.sending)
            }
        }

        @MainActor
        func setLoadingButtonTitle(_ title: String) {
            self.loadingTitle = title
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
}
