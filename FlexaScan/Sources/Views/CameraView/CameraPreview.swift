//
//  CameraPreview.swift
//  FlexaScan
//
//  Created by Rodrigo Ordeix on 20/12/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    @StateObject var videoOrientation = VideoOrientation()

    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        uiView.videoPreviewLayer.connection?.videoOrientation = videoOrientation.value
        uiView.videoPreviewLayer.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(videoOrientation)
    }
}

extension CameraPreview {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
            guard let layer = layer as? AVCaptureVideoPreviewLayer else {
                let previewLayer = AVCaptureVideoPreviewLayer()
                layer.addSublayer(previewLayer)
                return previewLayer
            }
            return layer
        }()
    }
}

extension CameraPreview {
    class VideoOrientation: ObservableObject {
        @Published var value: AVCaptureVideoOrientation

        init(_ value: AVCaptureVideoOrientation = .fromDeviceOrientation) {
            self.value = value
        }
    }
}

extension CameraPreview {
    class Coordinator {
        private let orientation: VideoOrientation
        private let notificationCenter = NotificationCenter.default
        private let observer: NSObjectProtocol?

        init(_ orientation: VideoOrientation) {
            self.orientation = orientation
            self.observer = notificationCenter.addObserver(
                forName: UIDevice.orientationDidChangeNotification,
                object: nil,
                queue: .main,
                using: { _ in
                    orientation.value = AVCaptureVideoOrientation.fromDeviceOrientation
                }
            )
        }

        deinit {
            if let observer {
                notificationCenter.removeObserver(observer)
            }
        }
    }
}

//#Preview {
//    CameraPreview()
//}
