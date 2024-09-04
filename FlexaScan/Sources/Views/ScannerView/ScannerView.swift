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
                    Color.black.ignoresSafeArea()
                }
                CameraPreview(session: viewModel.captureSession).ignoresSafeArea()
                HStack(alignment: .center) {
                    VStack(alignment: .center, spacing: 25) {
                        RoundedRectangle(cornerRadius: 36)
                            .stroke(Color.white, lineWidth: 3)
                            .aspectRatio(1, contentMode: .fit)
                        Text("Send, pay, or connect to a desktop website") // FIXME: use localized texts
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 15, weight: .regular)) // FIXME: use native font sizes
                            .frame(width: 178)
                            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                        if viewModel.showSettingAlert {
                            Button(action: openSettings) {
                                Text("Enable camera Access")
                                    .foregroundColor(.white)
                                    .font(.system(size: 17, weight: .bold))
                                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                            }
                        }
                    }.opacity(0.75)
                }.padding([.bottom, .horizontal], 58)
            }.toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 8) {
                        FlexaRoundedButton(.settings,
                                         color: navigationButtonColor,
                                         backgroundColor: navigationButtonBackgroundColor)
                        FlexaRoundedButton(.close,
                                         color: navigationButtonColor,
                                         backgroundColor: navigationButtonBackgroundColor,
                                         buttonAction: dismiss)
                    }
                }
            }.onAppear {
                viewModel.checkForCameraPermission()
            }.errorAlert(error: $cameraManager.error)
        }
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
        UIViewController.topMostViewController?.dismiss(animated: true)
    }
}
