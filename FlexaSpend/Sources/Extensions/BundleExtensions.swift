//
//  BundleExtensions.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 12/5/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation

extension Bundle {
    static var paymentBundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: FlexaSpend.self)
        #endif
    }

    var assetsBundle: Bundle {
        let bundleUrl = bundleURL.appendingPathComponent("FlexaSpendAssets.bundle")
        return Bundle(url: bundleUrl) ?? self
    }

    var colorsBundle: Bundle {
        let bundleUrl = bundleURL.appendingPathComponent("FlexaSpendColors.bundle")
        return Bundle(url: bundleUrl) ?? self
    }
}
