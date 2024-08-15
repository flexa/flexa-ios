//
//  InterfaceStyleExtensions.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/23/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

public extension FXTheme {
    /// Represent the interface styles the SDK support.
    enum InterfaceStyle: String, Codable {
        /// System's Interface style
        case automatic
        /// Light Interface style
        case light
        /// Dark Interface style
        case dark

        public var colorSheme: ColorScheme? {
            switch self {
            case .light:
                return .light
            case .dark:
                return .dark
            default:
                return nil
            }
        }
    }
}
