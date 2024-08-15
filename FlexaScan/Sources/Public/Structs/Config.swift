//
//  Config.swift
//  FlexaScan
//
//  Created by Rodrigo Ordeix on 9/7/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import Foundation
import Vision

public extension FlexaScan {
    struct Config {
        var allowedSymbols: [VNBarcodeSymbology]
        var minConfidence: VNConfidence

        public static let `default` = FlexaScan.Config()

        public init(allowedSymbols: [VNBarcodeSymbology] = [.qr, .pdf417, .code128], minConfidence: VNConfidence = 0.9) {
            self.allowedSymbols = allowedSymbols
            self.minConfidence = minConfidence
        }
    }
}
