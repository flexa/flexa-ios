//
//  NavigationTitleModifier.swift
//  FlexaUICore
//
//  Created by Rodrigo Ordeix on 8/30/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI
import SwiftUIIntrospect

public struct NavigationTitleModifier: ViewModifier {
    private(set) public var titleAttributes: [NSAttributedString.Key: Any]?
    private(set) public var largeTitleAttributes: [NSAttributedString.Key: Any]?
    private(set) public var largeTitleLeftMargin: CGFloat?
    private(set) public var prefersLargeTitles: Bool?

    init(
        titleAttributes: [NSAttributedString.Key: Any]? = nil,
        largeTitleAttributes: [NSAttributedString.Key: Any]? = nil,
        largeTitleLeftMargin: CGFloat? = nil,
        prefersLargeTitles: Bool? = nil
    ) {
        self.titleAttributes = titleAttributes
        self.largeTitleAttributes = largeTitleAttributes
        self.largeTitleLeftMargin = largeTitleLeftMargin
    }

    public func body(content: Content) -> some View {
        content
            .introspect(.navigationView(style: .stack), on: .iOS(.v14, .v15, .v16, .v17)) {
                if let titleAttributes {
                    $0.navigationBar.titleTextAttributes = titleAttributes
                }
                if let largeTitleAttributes {
                    $0.navigationBar.largeTitleTextAttributes = largeTitleAttributes
                }
                if let largeTitleLeftMargin {
                    $0.navigationBar.layoutMargins.left = largeTitleLeftMargin
                }
                if let prefersLargeTitles {
                    $0.navigationBar.prefersLargeTitles = prefersLargeTitles
                }
            }
    }
}

public extension View {
    func navigationTitleAttributes(
        titleAttributes: [NSAttributedString.Key: Any]? = nil,
        largeTitleAttributes: [NSAttributedString.Key: Any]? = nil,
        largeTitleLeftMargin: CGFloat? = nil,
        prefersLargeTitles: Bool? = nil
    ) -> some View {
        self.modifier(NavigationTitleModifier(
            titleAttributes: titleAttributes,
            largeTitleAttributes: largeTitleAttributes,
            largeTitleLeftMargin: largeTitleLeftMargin,
            prefersLargeTitles: prefersLargeTitles
        ))
    }
}
