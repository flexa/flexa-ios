//
//  ScannerView.swift
//  FlexaScan
//
//  Created by Rodrigo Ordeix on 9/7/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI

struct ScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: ViewModel
    @StateObject var cameraManager: CameraManager

    private var navigationButtonColor: Color {
        if !viewModel.isPermissionGranted || viewModel.showSettingAlert {
            return .black
        }
        return .white
    }

    private var navigationButtonBackgroundColor: Color {
        if !viewModel.isPermissionGranted || viewModel.showSettingAlert {
            return .white.opacity(0.7)
        }
        return .black.opacity(0.3)
    }

    private var flashlightButtonColor: Color {
        viewModel.isFlashlightOn ? .black : navigationButtonColor
    }

    private var flashlightButtonBackgroundColor: Color {
        viewModel.isFlashlightOn ? .white : navigationButtonBackgroundColor
    }

    private var flashlightImageName: String {
        viewModel.isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill"
    }

    init(onTransactionRequest: Flexa.TransactionRequestCallback? = nil,
         onSend: Flexa.SendHandoff? = nil) {

        let viewModel = ViewModel(
            onTransactionRequest: onTransactionRequest,
            onSend: onSend
        )

        _viewModel = StateObject(wrappedValue: viewModel)
        _cameraManager = StateObject(wrappedValue: viewModel.cameraManager)
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .center) {
                ZStack {
                    backgroundView
                }
                CameraPreview(session: viewModel.captureSession).ignoresSafeArea()
                HStack(alignment: .center) {
                    VStack(alignment: .center, spacing: 25) {
                        RoundedRectangle(cornerRadius: 36)
                            .stroke(Color.white, lineWidth: 3)
                            .aspectRatio(1, contentMode: .fit)
                        Text(ScanStrings.Scan.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 15, weight: .regular))
                            .frame(width: 178)
                            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                        if viewModel.showSettingAlert {
                            Button(action: openSettings) {
                                Text(ScanStrings.Scan.Buttons.EnableCamera.title)
                                    .foregroundColor(.white)
                                    .font(.system(size: 17, weight: .bold))
                                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                            }
                        }
                    }.opacity(0.75)
                }.padding([.bottom, .horizontal], 58)
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.isFlashlightAvailable {
                        FlexaRoundedButton(.custom(Image(systemName: flashlightImageName)),
                                           color: flashlightButtonColor,
                                           backgroundColor: flashlightButtonBackgroundColor
                        ) {
                            withAnimation {
                                viewModel.toggleFlashlight()
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        NavigationMenu {
                            FlexaRoundedButton(.settings,
                                               color: navigationButtonColor,
                                               backgroundColor: navigationButtonBackgroundColor
                            )
                        }
                        FlexaRoundedButton(.close,
                                         color: navigationButtonColor,
                                         backgroundColor: navigationButtonBackgroundColor,
                                         buttonAction: dismiss
                        )
                    }
                }
            }.onAppear {
                viewModel.setup()
            }.onDisappear {
                viewModel.stopCapturing()
            }
            .errorAlert(error: $cameraManager.error)
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        #if targetEnvironment(simulator)
        Color.purple.opacity(0.8).ignoresSafeArea()
        #else
        Color.black.ignoresSafeArea()
        #endif
    }

    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
        UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }

        UIApplication.shared.open(settingsUrl)
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}
