//
//  File.swift
//
//  Created by Rodrigo Ordeix on 2/7/24.
//

import SwiftUI
import SwiftUIIntrospect

extension View {
    @ViewBuilder
    func scrollContentBackgroundHidden(_ hide: Bool) -> some View {
        if #available(iOS 16.0, *) {
            scrollContentBackground(hide ? .hidden : .visible)
        } else {
            introspect(.form, on: .iOS(.v15)) {
                $0.backgroundColor = hide ? .clear : UIColor.systemGroupedBackground
            }
        }
    }
}
