//
//  WebView.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 2/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import SwiftUI

public extension FXTheme {
    struct WebView: FlexaThemable {
        public var webViewThemeConfig: String?

        public var backgroundColor: Color {
            Color(hex: (colorScheme == .light ? "#F2F2F2" : "#232524"))
        }

        public init(webViewThemeConfig: String? = nil) {
            self.webViewThemeConfig = webViewThemeConfig
        }

        // swiftlint:disable line_length
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<FXTheme.WebView.CodingKeys> = try decoder.container(keyedBy: FXTheme.WebView.CodingKeys.self)
            self.webViewThemeConfig = try container.decodeIfPresent(String.self, forKey: FXTheme.WebView.CodingKeys.webViewThemeConfig)
        }
        // swiftlint:enable line_length
    }
}
