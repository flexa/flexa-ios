//
//  BundleExtensions.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/23/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import UIKit

extension Bundle {
    public static var coreBundle: Bundle {
        Bundle(for: Flexa.self)
    }

    public var stringsBundle: Bundle {
        let bundleUrl = bundleURL.appendingPathComponent("Strings.bundle")
        return Bundle(url: bundleUrl) ?? self
    }

    var assetsBundle: Bundle {
        let bundleUrl = bundleURL.appendingPathComponent("Assets.bundle")
        return Bundle(url: bundleUrl) ?? self
    }

    public var version: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "(unknown version number)"
    }

    public var build: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "(unknown build number)"
    }

    public var displayName: String {
        infoDictionary?["CFBundleDisplayName"] as? String ?? name
    }

    public var name: String {
        infoDictionary?["CFBundleName"] as? String ?? "(unknown app name)"
    }
}
