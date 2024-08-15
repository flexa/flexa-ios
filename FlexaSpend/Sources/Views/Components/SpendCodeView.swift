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

        @Published var flexcode: Flexcode?
        @Published var expiringProgress = 0.0

        private var createdDate = Date()
        private let timeInterval: TimeInterval = 30
        private var timer: Timer?

        let updateTimerInterval: TimeInterval = 1
        let id = UUID()
        var asset: AssetWrapper

        var elapsedSeconds: TimeInterval {
            max(timeInterval - Date().timeIntervalSince(createdDate), 0.0)
        }

        var balance: String {
            asset.valueLabelTitleCase
        }

        var isExpired: Bool {
            Date() >= createdDate.addingTimeInterval(timeInterval)
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
            update()
            let timer = Timer.scheduledTimer(withTimeInterval: updateTimerInterval, repeats: true) { _ in
                self.update()
            }
            RunLoop.main.add(timer, forMode: .common)
            self.timer = timer
        }

        func stopTimer() {
            timer?.invalidate()
            timer = nil
        }

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
            flexcode = flexcodeGenerator.flexcode(for: asset.assetWithKey, type: .pdf417, scale: 5)
            FlexaLogger.debug("\(asset.assetSymbol): \(flexcode?.code ?? "missing flexcode")")
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
                    if let flexcode = viewModel.flexcode {
                        if let image = flexcode.image {
                            Image(uiImage: image)
                                .resizable()
                        } else {
                            Rectangle().fill(Color(.systemGray6))
                            Button {
                                UIPasteboard.general.string = flexcode.code
                            } label: {
                                Text(flexcode.code)
                                    .font(.title.bold())
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .foregroundColor(.primary)
                            }.padding()
                        }
                    } else {
                        Rectangle().fill(Color(.systemGray6))
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
                   leading: horizontalPadding,
                   bottom: 16,
                   trailing: horizontalPadding)
    }

    var backgroundColor: Color {
        theme.backgroundColor
    }
}
