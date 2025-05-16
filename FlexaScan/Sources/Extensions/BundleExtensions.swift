//
//  BundleExtensions.swift
//  FlexaScam
//
//  Created by Rodrigo Ordeix on 11/13/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation

extension Bundle {
    static var scanBundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: FlexaScan.self)
        #endif
    }

    var assetsBundle: Bundle {
        let bundleUrl = bundleURL.appendingPathComponent("FlexaScanAssets.bundle")
        return Bundle(url: bundleUrl) ?? self
    }
}
