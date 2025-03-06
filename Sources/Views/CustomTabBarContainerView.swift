//
//  CustomTabBarContainerView.swift
//  Flexa SDK
//
//  Created by Rodrigo Ordeix on 4/17/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore
import Factory

struct CustomTabBarContainerView<Content: View>: View {
    // MARK: - Instance properties
    @EnvironmentObject var modalState: SpendModalState
    @Binding var selection: TabBarItem
    @State private var tabs: [TabBarItem] = []
    let content: Content

    // MARK: - Initialization

    init(selection: Binding<TabBarItem>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .ignoresSafeArea().zIndex(1)
            if !modalState.visible {
                CustomTabBarView(tabs: tabs, selection: $selection)
                    .transition(.opacity)
                    .animation(.default, value: modalState.visible)
                    .zIndex(2)
            }
        }

        .onPreferenceChange(TabBarItemsPreferenceKey.self) { value in
            self.tabs = value
        }
    }
}
