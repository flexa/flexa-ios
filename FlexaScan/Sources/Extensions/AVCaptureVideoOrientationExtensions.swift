//
//  AVCaptureVideoOrientationExtensions.swift
//  FlexaScan
//
//  Created by Rodrigo Ordeix on 27/12/23.
//  Copyright © 2022 Flexa. All rights reserved.
//

import UIKit
import AVFoundation

extension AVCaptureVideoOrientation {
    static var fromDeviceOrientation: AVCaptureVideoOrientation {
        AVCaptureVideoOrientation(deviceOrientation: UIDevice.current.orientation)
    }

    init(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeRight
        case .landscapeRight:
            self = .landscapeLeft
        default:
            self = .portrait
        }
    }
}
