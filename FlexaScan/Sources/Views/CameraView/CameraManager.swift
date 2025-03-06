//
//  CameraManager.swift
//  FlexaScan
//
//  Created by Rodrigo Ordeix on 22/12/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import Foundation
import AVFoundation

extension CameraManager {
    enum Status {
        case configured
        case unconfigured
        case failed
    }
}

class CameraManager: NSObject, ObservableObject {
    @Published var status = Status.unconfigured
    @Published var error: Error?

    let captureSession = AVCaptureSession()
    let queue = DispatchQueue(label: "com.flexa.FlexaScan")
    weak var outputSampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?

    var device: AVCaptureDevice? {
        AVCaptureDevice.default(for: .video)
    }

    func setupCaptureSession() {
        queue.async {
            guard self.status == .unconfigured else {
                return
            }

            self.captureSession.beginConfiguration()
            self.setupInput()
            self.setupOutput()
            self.captureSession.commitConfiguration()

            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }

            DispatchQueue.main.async {
                self.status = .configured
            }

        }
    }

    func startCapturing() {
        guard status == .configured else {
            return
        }
        queue.async { [weak self] in
            guard let self else {
                return
            }
            if !captureSession.isRunning {
                DispatchQueue.global(qos: .background).async {
                    self.captureSession.startRunning()
                }
            }
        }
    }

    func stopCapturing() {
        guard status == .configured else {
            return
        }
        queue.async { [weak self] in
            guard let self else {
                return
            }

            if captureSession.isRunning {
                captureSession.stopRunning()
            }
        }
    }

    private func setupInput() {
        guard let device else {
            setError(withStatus: .unconfigured)
            FlexaLogger.error("Video device is unavailable")
            return
        }

        let input: AVCaptureDeviceInput

        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
            setError()
            FlexaLogger.error("Cannot create video device input")
            return
        }

        guard captureSession.canAddInput(input) else {
            setError()
            FlexaLogger.error("Cannot add input to capture session")
            return
        }
        captureSession.addInput(input)
    }

    private func setupOutput() {
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(outputSampleBufferDelegate, queue: queue)

        guard captureSession.canAddOutput(output) else {
            setError()
            FlexaLogger.error("Cannot add output to capture session")
            return
        }

        captureSession.addOutput(output)
    }

    private func setError(withStatus status: Status = .failed) {
        DispatchQueue.main.async {
            self.error = ReasonableError.custom(
                title: ScanStrings.Errors.CameraAccess.title,
                message: ScanStrings.Errors.CameraAccess.message
            )
            self.status = status
        }
    }
}
