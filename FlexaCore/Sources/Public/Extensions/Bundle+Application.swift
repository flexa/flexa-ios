//
//  Bundle+Application.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 07/30/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import UIKit

public extension Bundle {
    static var applicationIcon: UIImage? {
        guard let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcons = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcons["CFBundleIconFiles"] as? [String],
              let iconImageName = iconFiles.last else {
            return nil
        }
        return UIImage(named: iconImageName)
    }

    static var applicationDisplayName: String {
        Bundle.main.displayName
    }

    static var applicationVersion: String {
        Bundle.main.version
    }

    static var applicationBuild: String {
        Bundle.main.build
    }

    static var applicationBundleId: String {
        Bundle.main.bundleIdentifier ?? "unknown"
    }
}
