//
//  ScannerViewModel.swift
//  FlexaScan
//
//  Created by Rodrigo Ordeix on 20/12/23.
//  Copyright © 2022 Flexa. All rights reserved.
//

import AVFoundation
import SwiftUI
import Factory
import Vision

extension ScannerView {
    class ViewModel: NSObject, ObservableObject {
        private let config = Container.shared.scanConfig()
        @Published var cameraManager = CameraManager()
        @Published var showSettingAlert = false
        @Published var isPermissionGranted: Bool = false

        var captureSession = AVCaptureSession()
        var onTransactionRequest: Flexa.TransactionRequestCallback?
        var onSend: Flexa.SendHandoff?

        private lazy var detectCodeRequest = { VNDetectBarcodesRequest(completionHandler: processCodeRequest) }()

        init(onTransactionRequest: Flexa.TransactionRequestCallback? = nil,
             onSend: Flexa.SendHandoff? = nil) {
            super.init()
            self.onTransactionRequest = onTransactionRequest
            self.onSend = onSend
            captureSession = cameraManager.captureSession
            cameraManager.outputSampleBufferDelegate = self
        }

        deinit {
            cameraManager.stopCapturing()
        }

        func checkForCameraPermission() {
            let videoStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                if videoStatus == .authorized {
                    isPermissionGranted = true
                    setupCamera()
                } else if videoStatus == .notDetermined {
                    AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: requestAccessHandler)
                } else if videoStatus == .denied {
                    isPermissionGranted = false
                    showSettingAlert = true
                }
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ScannerView.ViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            FlexaLogger.error("Cannot create CMSampleBufferGetImageBuffer")
            return
        }

        let imageRequestHandler = VNImageRequestHandler(
            cvPixelBuffer: imageBuffer,
            orientation: .right
        )

        do {
            try imageRequestHandler.perform([detectCodeRequest])
        } catch let error {
            FlexaLogger.error(error)
        }
    }
}

// MARK: - Private
private extension ScannerView.ViewModel {
    func processCodeRequest(_ request: VNRequest, _ error: Error?) {
        if let error = error {
            FlexaLogger.error(error)
            return
        }

        guard let barcodes = request.results, !barcodes.isEmpty else {
            return
        }

        let data = barcodes
            .compactMap { $0 as? VNBarcodeObservation }
            .filter {
                $0.confidence > self.config.minConfidence &&
                self.config.allowedSymbols.contains($0.symbology) &&
                $0.payloadStringValue != nil
            }
            .map { FlexaScan.Code(uriString: $0.payloadStringValue ?? "", symbology: $0.symbology) }

        guard !data.isEmpty else {
            return
        }

        DispatchQueue.main.async {
            // Process code and make callbacks
        }
    }

    func setupCamera() {
        cameraManager.setupCaptureSession()
    }

    func requestAccessHandler(_ granted: Bool) {
        DispatchQueue.main.async { [self] in
            if granted {
                isPermissionGranted = true
                setupCamera()
            } else {
                isPermissionGranted = false
                showSettingAlert = true
            }
        }
    }
}
