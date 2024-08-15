import Foundation
import SwiftUI

public extension FXTheme.View {
    enum CodingKeys: String, CodingKey {
        case backgroundColorName = "backgroundColor"
        case padding, borderRadius
    }
}

public extension FXTheme {
    class View: FlexaThemable {
        var defaultBackgroundColor: Color {
            Color(UIColor(dynamicProvider: { trait in
                    UIColor(hex: trait.userInterfaceStyle == .dark ? "#232524" : "#F2F2F2") ?? .systemBackground
                }))
        }

        private var backgroundColorName: String?

        public var padding: CGFloat? = 0
        public var borderRadius: CGFloat = 0

        public var backgroundColor: Color {
            colorBy(name: backgroundColorName, fallbackColor: defaultBackgroundColor)
        }

        public required init(padding: CGFloat? = nil, borderRadius: CGFloat = 0, backgroundColorName: String? = nil) {
            self.padding = padding
            self.borderRadius = borderRadius
            self.backgroundColorName = backgroundColorName
        }

        // swiftlint:disable line_length
        public required init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<FXTheme.View.CodingKeys> = try decoder.container(keyedBy: FXTheme.View.CodingKeys.self)
            self.backgroundColorName = try container.decodeIfPresent(String.self, forKey: FXTheme.View.CodingKeys.backgroundColorName)
            self.padding = try container.decodeIfPresent(CGFloat.self, forKey: FXTheme.View.CodingKeys.padding)
            self.borderRadius = try container.decodeIfPresent(CGFloat.self, forKey: FXTheme.View.CodingKeys.borderRadius) ?? 0
        }
        // swiftlint:enable line_length
    }
}
