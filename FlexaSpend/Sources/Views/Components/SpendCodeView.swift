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
            asset.valueLabelTitleCase
        }

        var isExpired: Bool {
            Date() >= createdDate.addingTimeInterval(timeInterval)
        }

        var hasFlexcodes: Bool {
            !flexcodes.isEmpty
        }

        var hasImages: Bool {
            flexcodes.values.contains {
                $0.image != nil
            }
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
            FlexaLogger.info("\(asset.assetSymbol): \(code ?? "missing flexcode")")

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
            ZStack {
                Button {
                    buttonAction()
                } label: {
                    HStack {
                        Text(viewModel.balance)
                            .font(.body.weight(.light))
                            .foregroundColor(.secondary)
                            .frame(height: 34)
                            .padding(.leading, 16)
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                            .frame(width: 14, height: 14, alignment: .center)
                            .padding(.trailing, 14)
                    }.modifier(RoundedView(color: .secondary.opacity(0.1)))
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
