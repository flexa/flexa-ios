//
//  FlexaAuthNavigationBarModifier.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/14/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI
import SwiftUIIntrospect

extension View {
    func flexaAuthNavigationbar() -> some View {
        modifier(FlexaAuthNavigationBarModifier())
    }
}

struct FlexaAuthNavigationBarModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .introspect(.navigationView(style: .stack), on: .iOS(.v15)) { navController in
                navController.navigationBar.tintColor = UIColor(Color.flexaTintColor)
                navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
                navController.navigationBar.shadowImage = UIImage()
                navController.navigationBar.isTranslucent = true
            }

    }
}
