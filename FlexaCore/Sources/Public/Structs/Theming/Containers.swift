//
//  Containers.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/19/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import SwiftUI

public extension FXTheme {
    struct Containers: FlexaThemable {
        public static let `default` = Containers()

        public var empty: Empty
        public var notifications: Notification
        public var content: Content

        public init(empty: Empty = .default,
                    notifications: Notification = .default,
                    content: Content = .default
        ) {
            self.empty = empty
            self.notifications = notifications
            self.content = content
        }
    }
}

public extension FXTheme.Containers {
    class Empty: FXTheme.View {
        public static let `default` = Empty(padding: 74, borderRadius: 14)

        override var defaultBackgroundColor: Color {
            Color(
                UIColor(dynamicProvider: { trait in
                    UIColor(hex: trait.userInterfaceStyle == .dark ? "#343434" : "#e5e5ea") ?? .systemBackground
                })
            )
        }
    }
}

public extension FXTheme.Containers {
    class Notification: FXTheme.View {
        private static var defaultBorderRadius: CGFloat {
            if Flexa.supportsGlass {
                return 20
            }
            return 14
        }
        public static let `default` = Notification(padding: 16, borderRadius: defaultBorderRadius)

        override var defaultBackgroundColor: Color {
            Color(
                UIColor(dynamicProvider: { trait in
                    UIColor(hex: trait.userInterfaceStyle == .dark ? "#343434" : "#ffffff") ?? .systemBackground
                })
            )
        }
    }
}

public extension FXTheme.Containers {
    class Content: FXTheme.View {
        private static var defaultBorderRadius: CGFloat {
            if Flexa.supportsGlass {
                return 20
            }
            return 14
        }
        public static let `default` = Content(padding: 42, borderRadius: defaultBorderRadius)

        override var defaultBackgroundColor: Color {
            Color(
                UIColor(dynamicProvider: { trait in
                    UIColor(hex: trait.userInterfaceStyle == .dark ? "#343434" : "#ffffff") ?? .systemBackground
                })
            )
        }
    }
}
