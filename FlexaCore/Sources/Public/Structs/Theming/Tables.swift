//
//  FlexaCore.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/19/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import SwiftUI

public extension FXTheme {
    class Tables: FlexaThemable {
        public static let `default` = Tables()

        public var borderRadius: CGFloat
        public var margin: CGFloat
        public var cellSpacing: CGFloat
        public var headingPadding: CGFloat
        public var footerPadding: CGFloat
        public var shadow: FXTheme.Shadow
        public var cell: Cells
        public var separator: Separator

        init(borderRadius: CGFloat = 6,
             margin: CGFloat = 20,
             cellSpacing: CGFloat = 0,
             headingPadding: CGFloat = 0,
             footerPadding: CGFloat = 0,
             shadow: FXTheme.Shadow = .default,
             cell: Cells = .default,
             separator: Separator = .default) {
            self.borderRadius = borderRadius
            self.margin = margin
            self.cellSpacing = cellSpacing
            self.headingPadding = headingPadding
            self.footerPadding = footerPadding
            self.shadow = shadow
            self.cell = cell
            self.separator = separator
        }

        // swiftlint:disable line_length
        required public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<FXTheme.Tables.CodingKeys> = try decoder.container(keyedBy: FXTheme.Tables.CodingKeys.self)
            self.borderRadius = try container.decodeIfPresent(CGFloat.self, forKey: FXTheme.Tables.CodingKeys.borderRadius) ?? Tables.default.borderRadius
            self.margin = try container.decodeIfPresent(CGFloat.self, forKey: FXTheme.Tables.CodingKeys.margin) ?? Tables.default.margin
            self.cellSpacing = try container.decodeIfPresent(CGFloat.self, forKey: FXTheme.Tables.CodingKeys.cellSpacing) ?? Tables.default.cellSpacing
            self.headingPadding = try container.decodeIfPresent(CGFloat.self, forKey: FXTheme.Tables.CodingKeys.headingPadding) ?? Tables.default.headingPadding
            self.footerPadding = try container.decodeIfPresent(CGFloat.self, forKey: FXTheme.Tables.CodingKeys.footerPadding) ?? Tables.default.footerPadding
            self.shadow = try container.decodeIfPresent(FXTheme.Shadow.self, forKey: FXTheme.Tables.CodingKeys.shadow) ?? Tables.default.shadow
            self.cell = try container.decodeIfPresent(FXTheme.Tables.Cells.self, forKey: FXTheme.Tables.CodingKeys.cell) ?? Tables.default.cell
            self.separator = try container.decodeIfPresent(FXTheme.Tables.Separator.self, forKey: FXTheme.Tables.CodingKeys.separator) ?? Tables.default.separator
        }
        // swiftlint:enable line_lenght
    }
}

public extension FXTheme.Tables {
    class Cells: FXTheme.View {
        public static let `default` = Cells()

        override var defaultBackgroundColor: Color {
            Color(
                UIColor(dynamicProvider: { trait in
                    UIColor(hex: trait.userInterfaceStyle == .dark ? "#343434" : "#ffffff") ?? .systemBackground
                })
            )
        }
    }
}

public extension FXTheme.Tables {
    class Separator: FlexaThemable {
        enum CodingKeys: String, CodingKey {
            case colorName = "color"
        }

        public static let `default` = Separator()

        private var colorName: String?

        public var color: Color? {
            colorBy(name: colorName)
        }
    }
}
