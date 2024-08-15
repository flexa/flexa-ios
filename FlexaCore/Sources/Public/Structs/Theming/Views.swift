//
//  Views.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/19/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import SwiftUI

public extension FXTheme {
    struct Views: FlexaThemable {
        public static let `default` = Views()

        public var primary: Primary
        public var sheet: Sheet

        public init(primary: Primary = .default, sheet: Sheet = .default) {
            self.primary = primary
            self.sheet = sheet
        }
    }
}

public extension FXTheme.Views {
    class Primary: FXTheme.View {
        public static let `default` = Primary(padding: 24, borderRadius: 16)
    }
}

public extension FXTheme.Views {
    class Sheet: FXTheme.View {
        public static let `default` = Sheet(padding: 24, borderRadius: 8)
    }
}
