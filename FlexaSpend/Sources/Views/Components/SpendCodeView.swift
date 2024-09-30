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

        @Published var expiringProgress = 0.0
        @Published var code: String = ""
        @Published var pdf417Image: UIImage = UIImage()
        @Published var code128Image: UIImage = UIImage()

        private var flexcodes: [FlexcodeSymbology: Flexcode] = [:]

        private var createdDate = Date()
        private let timeInterval: TimeInterval = 30
        private var timer: Timer?

        let updateTimerInterval: TimeInterval = 1
        let id = UUID()
        var asset: AssetWrapper

        var gradientMiddleColor: Color {
            asset.assetColor ?? .purple
        }

        var elapsedSeconds: TimeInterval {
            max(timeInterval - Date().timeIntervalSince(createdDate), 0.0)
        }

        var balance: String {
            if let balance = asset.usdBalance, asset.isUpdatingBalance {
                return L10n.Payment.Balance.title(balance.asCurrency)
            } else {
                return asset.valueLabelTitleCase
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
            asset.availableUSDBalance
        }

        init(asset: AssetWrapper) {
            self.asset = asset
            updateCode()
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        func startTimer() {
            stopTimer()
            Task {
                await update()
            }
            let timer = Timer.scheduledTimer(withTimeInterval: updateTimerInterval, repeats: true) { _ in
                Task {
                    await self.update()
                }
            }
            RunLoop.main.add(timer, forMode: .common)
            self.timer = timer
        }

        func stopTimer() {
            timer?.invalidate()
            timer = nil
        }

        @MainActor
        private func update() {
            if isExpired {
                updateCode()
            } else if elapsedSeconds < updateTimerInterval {
                expiringProgress = 1
            } else {
                expiringProgress = Date().timeIntervalSince(createdDate) / timeInterval
            }
        }

        private func updateCode() {
            flexcodes = flexcodeGenerator.flexcodes(for: asset.assetWithKey)
            let code = flexcodes.values.first?.code
            FlexaLogger.debug("\(asset.assetSymbol): \(code ?? "no-code")")
            self.code = code ?? ""
            self.pdf417Image = flexcodes[.pdf417]?.image ?? UIImage()
            self.code128Image = flexcodes[.code128]?.image ?? UIImage()

            createdDate = Date()
            expiringProgress = 0
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
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
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
