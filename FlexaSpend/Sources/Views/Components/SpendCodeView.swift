//
//  SpendCodeView.swift
//  FlexaSpend
//
//  Created by Marcelo Korjenioski on 12/15/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore
import Factory

extension SpendCodeView {
    class ViewModel: Identifiable, Hashable, ObservableObject {
        @Injected(\.flexcodeGenerator) var flexcodeGenerator
        @Injected(\.accountRepository) var accountRepository

        @Published var code: String = ""
        @Published var pdf417Image: UIImage = UIImage()
        @Published var code128Image: UIImage = UIImage()
        @Published var account: Account?

        private var flexcodes: [FlexcodeSymbology: Flexcode] = [:]

        private var createdDate = Date()
        private let timeInterval: TimeInterval = 30
        let id = UUID()
        var asset: AssetWrapper

        var gradientMiddleColor: Color {
            asset.assetColor ?? .purple
        }

        var accountBalance: Decimal {
            account?.balance?.amount?.decimalValue ?? 0
        }

        var balance: String {
            let balance = ((asset.balanceInLocalCurrency ?? 0) + accountBalance).asCurrency

            if asset.isUpdatingBalance {
                return L10n.Payment.Balance.title(balance)
            } else {
                return L10n.Payment.CurrencyAvaliable.title(balance)
            }
        }

        var isExpired: Bool {
            Date() >= createdDate.addingTimeInterval(timeInterval)
        }

        var isUpdatingBalance: Bool {
            asset.isUpdatingBalance
        }

        var hasFlexcodes: Bool {
            !flexcodes.isEmpty
        }

        var hasImages: Bool {
            flexcodes.values.contains {
                $0.image != nil
            }
        }

        var availableUSDBalance: Decimal? {
            asset.availableBalanceInLocalCurrency
        }

        init(asset: AssetWrapper) {
            self.asset = asset
            flexcodes = flexcodeGenerator.flexcodes(for: asset.oneTimekey)
            createdDate = Date()
            updateCode()
            account = accountRepository.account
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        func updateIfNeeded() {
            guard self.isExpired else {
                return
            }
            self.flexcodes = self.flexcodeGenerator.flexcodes(for: self.asset.oneTimekey)
            self.createdDate = Date()
            Task {
                await update()
            }
        }

        @MainActor
        private func update() {
            updateCode()
        }

        func updateCode() {
            let code = flexcodes.values.first?.code
            self.code = code ?? ""
            self.pdf417Image = flexcodes[.pdf417]?.image ?? UIImage()
            self.code128Image = flexcodes[.code128]?.image ?? UIImage()
        }

        func loadAccount() {
            Task {
                if let account = accountRepository.account {
                    await handleAccountUpdate(account)
                    return
                }
                do {
                    let account = try await accountRepository.getAccount()
                    await handleAccountUpdate(account)
                } catch let error {
                    FlexaLogger.error(error)
                    await handleAccountUpdate(accountRepository.account)
                }
            }
        }

        @MainActor
        private func handleAccountUpdate(_ account: Account?) {
            self.account = account
        }

        static func == (lhs: SpendCodeView.ViewModel, rhs: SpendCodeView.ViewModel) -> Bool {
            lhs.id.uuidString == rhs.id.uuidString
        }
    }
}

struct SpendCodeView: View {
    var buttonAction: () -> Void

    @StateObject private var viewModel: ViewModel
    @Environment(\.theme.containers.content) var theme

    public init(viewModel: ViewModel, buttonAction: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.buttonAction = buttonAction
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            VStack {
                ZStack {
                    if viewModel.hasFlexcodes {
                        if viewModel.hasImages {
                            FlexcodeView(
                                pdf417Image: $viewModel.pdf417Image,
                                code128Image: $viewModel.code128Image,
                                gradientMiddleColor: viewModel.gradientMiddleColor
                            )
                        } else {
                            FlexcodeView.placeholder
                            Button {
                                UIPasteboard.general.string = viewModel.code
                            } label: {
                                Text(viewModel.code)
                                    .font(.title.bold())
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .foregroundColor(.primary)
                            }.padding()
                        }
                    } else {
                        FlexcodeView.placeholder
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(padding)
            }
            Button {
                buttonAction()
            } label: {
                HStack {
                    Text(viewModel.balance)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                        .frame(height: 34)
                        .padding(.leading, 16)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                        .padding(.trailing, 14)
                }
            }
            if viewModel.isUpdatingBalance {
                HStack(spacing: 10) {
                    ProgressView()
                    Text(L10n.Common.updating.uppercased())
                        .foregroundColor(.secondary)
                        .font(.subheadline.weight(.medium))
                        .opacity(0.5)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding([.bottom], 21)
        .modifier(RoundedView(color: backgroundColor, cornerRadius: cornerRadius))
        .onAppear {
            viewModel.loadAccount()
        }
    }
}

// MARK: Theming
private extension SpendCodeView {
    var cornerRadius: CGFloat {
        theme.borderRadius
    }

    var horizontalPadding: CGFloat {
        theme.padding ?? 0
    }

    var padding: EdgeInsets {
        EdgeInsets(top: 36,
                   leading: 0,
                   bottom: 16,
                   trailing: 0)
    }

    var backgroundColor: Color {
        theme.backgroundColor
    }
}
