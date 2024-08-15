//
//  TabViewPagerColorsModifier.swift
//  FlexaUICore
//
//  Created by Rodrigo Ordeix on 8/9/24.
//  Copyright © 2024 Flexa. All rights reserved
//

import SwiftUI

public extension View {
    func tabViewPagerColors(defaultColor: Color? = nil, selectedColor: Color? = nil) -> some View {
        self.modifier(TabViewPagerColorsModifier(defaultColor: defaultColor, selectedColor: selectedColor))
    }
}

struct TabViewPagerColorsModifier: ViewModifier {
    var defaultColor: Color?
    var selectedColor: Color?

    @State private var originalSelectedColor: UIColor?
    @State private var originalDefaultColor: UIColor?

    func body(content: Content) -> some View {
        content
            .onAppear {
                let appearance = UIPageControl.appearance()
                originalSelectedColor = appearance.currentPageIndicatorTintColor
                originalDefaultColor = appearance.pageIndicatorTintColor

                if let selectedColor {
                    appearance.currentPageIndicatorTintColor = UIColor(selectedColor)
                }
                if let defaultColor {
                    appearance.pageIndicatorTintColor = UIColor(defaultColor)
                }
            }
            .onDisappear {
                guard let originalSelectedColor,
                      let originalDefaultColor else {
                    return
                }

                let appearance = UIPageControl.appearance()
                appearance.currentPageIndicatorTintColor = originalSelectedColor
                appearance.pageIndicatorTintColor = originalDefaultColor
            }
    }
}
