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

    func setupCaptureSession() {
        queue.async {
            guard self.status == .unconfigured else {
                return
            }

            self.captureSession.beginConfiguration()
            self.setupInput()
            self.setupOutput()
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }

    func startCapturing() {
        queue.async { [weak self] in
            guard let self else {
                return
            }
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
        }
    }

    func stopCapturing() {
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
        guard let camera = AVCaptureDevice.default(for: .video) else {
            setError(withStatus: .unconfigured)
            FlexaLogger.error("Video device is unavailable")
            return
        }

        let input: AVCaptureDeviceInput

        do {
            input = try AVCaptureDeviceInput(device: camera)
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
        status = .configured
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
            self.error = ReasonableError.custom(title: "Camera error", message: "There was an error getting the video device")
            self.status = status
        }
    }
}
