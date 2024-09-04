//
//  SpendTabBottomView.swift
//  Flexa SDK
//
//  Created by Rodrigo Ordeix on 4/17/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore

struct SpendTabBottomView: View {
    // MARK: - Instance properties

    let tabbarItems: [TabItemData]
    var height: CGFloat = 70
    var width: CGFloat = UIScreen.main.bounds.width - 32
    @Binding var selectedIndex: Int

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(tabbarItems.indices, id: \.self) { index in
                let item = tabbarItems[index]
                Button {
                    withAnimation {
                        self.selectedIndex = index
                    }
                } label: {
                    let isSelected = selectedIndex == index
                    TabItemView(data: item, isSelected: isSelected)
                }
            }
        }
        .frame(width: width, height: height)
        .background(Color.gray.opacity(0.8))
        .cornerRadius(16)
        .shadow(radius: 5, x: 0, y: 4)
        .padding(0)
    }
}

struct TabItemView: View {
    let data: TabItemData
    let isSelected: Bool

    var body: some View {
        Text(data.title)
            .foregroundColor(isSelected ? .black : .white)
            .font(.title2)
            .padding()
            .modifier(RoundedView(color: isSelected ? .white : .gray.opacity(0)))
    }
}

struct TabItemData {
    let title: String
}
