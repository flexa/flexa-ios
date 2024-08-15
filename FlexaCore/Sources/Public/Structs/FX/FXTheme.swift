//
//  FXTheme.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 14/12/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI
import Factory

public protocol FlexaThemable: Codable {
}

public extension FlexaThemable {
    var colorScheme: ColorScheme? {
        Container.shared.flexaClient().theme.interfaceStyle.colorSheme
    }

    var colors: [String: Color] {
        Container.shared.flexaClient().theme.colors
    }

    func colorBy(name: String?, fallbackColor: Color) -> Color {
        colorBy(name: name) ?? fallbackColor
    }

    func colorBy(name: String?) -> Color? {
        guard let name else {
            return nil
        }
        return colors[name]
    }
}

public struct FXTheme: FlexaThemable {
    enum CodingKeys: String, CodingKey {
        case interfaceStyle, views, containers, tables
        case webView = "webViewThemeConfig"
    }

    /// Indicates the interface style the sdk will display (`light`, `dark` or `automatic`)
    public var interfaceStyle: InterfaceStyle
    public var views: Views
    public var webView: FXTheme.WebView = WebView()
    public var containers: Containers
    public var tables: Tables
    //        var texts: Texts
    //        var controls: Controls
    public var colors: [String: Color]
    public static let `default` = Self.init()

    public static func fromJsonString(_ json: String) -> Self {
        guard let data = json.data(using: .utf8), !json.isEmpty else {
            return .default
        }

        var theme = (try? JSONDecoder().decode(FXTheme.self, from: data)) ?? .default
        let dictionary = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]

        guard let dictionary else {
            return theme
        }

        if let webViewThemeConfig = dictionary[CodingKeys.webView.rawValue] {
            let webViewThemeConfigData = try? JSONSerialization.data(withJSONObject: webViewThemeConfig)
            if let data = webViewThemeConfigData,
               let stringTheme = String(data: data, encoding: .utf8) {
                theme.webView = WebView(webViewThemeConfig: stringTheme)
            }
        }

        if let colors = dictionary["colors"] as? [String: [String: String]] {
            let lightColors = colors["light"]
            let darkColors = colors["dark"]
            var newColors: [String: Color] = [:]

            lightColors?.forEach { key, value in
                newColors[key] = Color(
                    lightColor: UIColor(string: value),
                    darkColor: UIColor(string: darkColors?[key] ?? "")
                )
            }

            darkColors?.forEach { key, value in
                if newColors[key] == nil {
                    newColors[key] = Color(
                        lightColor: UIColor(string: lightColors?[key] ?? ""),
                        darkColor: UIColor(string: value)
                    )
                }
            }
            theme.colors = newColors
        }

        return theme
    }

    init() {
        interfaceStyle = .automatic
        views = .default
        containers = .default
        tables = .default
        webView = FXTheme.WebView()
        colors = [:]
    }

    public init(interfaceStyle: InterfaceStyle = .automatic,
                views: Views = .default,
                containers: Containers = .default,
                tables: Tables = .default,
                colors: [String: Color] = [:]) {
        self.interfaceStyle = interfaceStyle
        self.views = views
        self.containers = containers
        self.tables = tables
        self.webView = FXTheme.WebView()
        self.colors = colors
    }

    // swiftlint:disable line_length
    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<FXTheme.CodingKeys> = try decoder.container(keyedBy: FXTheme.CodingKeys.self)
        self.interfaceStyle = try container.decodeIfPresent(InterfaceStyle.self, forKey: CodingKeys.interfaceStyle) ?? .automatic
        self.views = try container.decodeIfPresent(Views.self, forKey: CodingKeys.views) ?? Self.default.views
        self.containers = try container.decodeIfPresent(Containers.self, forKey: CodingKeys.containers) ?? Self.default.containers
        self.tables = try container.decodeIfPresent(Tables.self, forKey: CodingKeys.tables) ?? Self.default.tables
        self.colors = [:]
    }

    // swiftlint:enable line_length
}

public struct FXThemeKey: EnvironmentKey {
    public static var defaultValue: FXTheme = .default
}

public extension EnvironmentValues {
    var theme: FXTheme {
        get { self[FXThemeKey.self] }
        set { self[FXThemeKey.self] = newValue }
    }
}

public extension View {
    func theme(_ value: FXTheme) -> some View {
        environment(\.theme, value)
    }
}
