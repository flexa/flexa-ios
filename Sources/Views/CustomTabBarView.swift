//
//  CustomTabBarView.swift
//  Flexa SDK
//
//  Created by Rodrigo Ordeix on 4/17/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI

struct CustomTabBarView: View {
    let tabs: [TabBarItem]
    @Binding var selection: TabBarItem
    @Namespace private var namespace

    var body: some View {
        tabBarVersion
    }
}

extension CustomTabBarView {
    private func tabView(tab: TabBarItem) -> some View {
        VStack {
            Text(tab.title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
        }
        .foregroundColor(selection == tab ? .black : .white)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .background(
            ZStack {
                if selection == tab {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .matchedGeometryEffect(id: "background_rectangle", in: namespace)
                }
            }
        )
    }

    private func switchToTab(tab: TabBarItem) {
        withAnimation(.easeIn) {
            selection = tab
        }
    }

    private var tabBarVersion: some View {
        ZStack {
            HStack {
                ForEach(tabs, id: \.self) { tab in
                    tabView(tab: tab)
                        .onTapGesture {
                            switchToTab(tab: tab)
                        }
                }
            }
            .padding(1)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(Color.gray.opacity(0.6))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 30)
    }
}
