//
//  BrandView.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 8/11/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI

struct BrandView: UIViewControllerRepresentable {
    private var url: URL?

    init(_ url: URL? = nil) {
        self.url = url
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = BrandViewController()
        if let url {
            viewController.url = url
        }
        return UINavigationController(rootViewController: viewController)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}
