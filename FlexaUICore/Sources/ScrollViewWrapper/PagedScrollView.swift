//
//  PagedScrollView.swift
//  FlexaUICore
//
//  Created by Rodrigo Ordeix on 8/28/23.
//  Copyright © 2022 Flexa. All rights reserved.
//

import SwiftUI

struct PagedScrollView<Content: View>: UIViewRepresentable {
    private var itemSize: CGSize
    private var spacing: CGFloat
    private var itemsCount: Int
    private let content: () -> Content

    @Binding var selectedIndex: Int

    private var contentWidth: CGFloat {
        CGFloat(itemsCount) * (itemSize.width + spacing)
    }

    init(itemsCount: Int,
         selectedIndex: Binding<Int>,
         itemSize: CGSize,
         spacing: CGFloat,
         @ViewBuilder content: @escaping () -> Content) {
        self.itemsCount = itemsCount
        self.itemSize = itemSize
        self.spacing = spacing
        self.content = content
        self._selectedIndex = selectedIndex
    }

    func makeUIView(context: UIViewRepresentableContext<PagedScrollView>) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.backgroundColor = .clear
        scrollView.delegate = context.coordinator
        scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        scrollView.clipsToBounds = false

        let controller = UIHostingController(rootView: content())
        controller.view.backgroundColor = .clear
        controller.view.sizeToFit()

        scrollView.addSubview(controller.view)
        scrollView.contentSize = CGSize(width: contentWidth, height: itemSize.height)

        scrollToPage(scrollView: scrollView, page: selectedIndex, animated: false)
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: UIViewRepresentableContext<PagedScrollView>) {
        let subviews = uiView.subviews
        subviews.forEach {
            $0.removeFromSuperview()
        }
        let controller = UIHostingController(rootView: content())
        controller.view.backgroundColor = .clear
        controller.view.sizeToFit()

        uiView.addSubview(controller.view)
        uiView.contentSize = CGSize(width: contentWidth, height: itemSize.height)

        scrollToPage(scrollView: uiView, page: selectedIndex)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        let parent: PagedScrollView<Content>

        init(parent: PagedScrollView<Content>) {
            self.parent = parent
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                parent.selectedIndex = scrollView.currentPage
            }
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            parent.selectedIndex = scrollView.currentPage
        }
    }

    private func scrollToPage(scrollView: UIScrollView, page: Int, animated: Bool = true) {
        let safePage = CGFloat(max(0, min(page, itemsCount - 1)))
        let offset = safePage * (itemSize.width + spacing)
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
    }
}

private extension UIScrollView {
    var currentPage: Int {
        Int((contentOffset.x + frame.size.width / 2) / frame.width)
    }
}
