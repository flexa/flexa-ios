//
//  SpendSnapCarousel.swift
//  FlexaUICore
//
//  Created by Rodrigo Ordeix on 8/28/23.
//  Copyright © 2022 Flexa. All rights reserved.
//

import SwiftUI

public struct SpendSnapCarousel<Content: View, T: Identifiable & Hashable>: View {
    private var content: (T) -> Content
    private var itemSize: CGSize
    private var width: CGFloat
    private var spacing: CGFloat
    private var horizontalPadding: CGFloat
    private var contentWidth: CGFloat {
        CGFloat(items.count) * itemSize.width + CGFloat(items.count - 1) * spacing
    }
    private var items: [T] = []

    @Binding var selectedIndex: Int
    @State private var activeCardIndex: Int?

    public init(items: [T],
                selectedIndex: Binding<Int>,
                itemSize: CGSize,
                width: CGFloat = UIScreen.main.bounds.width,
                spacing: CGFloat,
                horizontalPadding: CGFloat,
                @ViewBuilder content: @escaping (T) -> Content) {
        self.itemSize = itemSize
        self.width = width
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
        self.content = content
        self.items = items
        self._selectedIndex = selectedIndex
        self.activeCardIndex = selectedIndex.wrappedValue
    }

    public var body: some View {
        if #available(iOS 17.0, *) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(items) { item in
                        content(item)
                            .frame(width: itemSize.width, height: itemSize.height)
                            .id(items.firstIndex(of: item))
                    }
                }
                .frame(height: itemSize.height)
                .padding(.horizontal, spacing / 2)
                .scrollTargetLayout()
            }
            .frame(height: itemSize.height)
            .padding(.horizontal, horizontalPadding - spacing / 2)
            .scrollTargetBehavior(.paging)
            .scrollClipDisabled()
            .scrollPosition(id: $activeCardIndex, anchor: .center)
            .onChange(of: activeCardIndex) {
                withAnimation {
                    selectedIndex = activeCardIndex ?? 0
                }
            }
            .onChange(of: selectedIndex) {
                withAnimation {
                    activeCardIndex = selectedIndex
                }
            }
        } else {
            PagedScrollView(
                itemsCount: items.count,
                selectedIndex: $selectedIndex,
                itemSize: itemSize,
                spacing: spacing
            ) {
                LazyHStack(spacing: spacing) {
                    ForEach(items, id: \.self) { item in
                        content(item)
                            .frame(width: itemSize.width, height: itemSize.height)
                    }
                }.frame(height: itemSize.height)
                    .padding(.horizontal, spacing / 2)
            }
            .frame(height: itemSize.height)
            .padding(.horizontal, horizontalPadding - spacing / 2)
        }
    }
}
