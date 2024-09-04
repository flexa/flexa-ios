//
//  BrandView.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 8/11/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI

struct BrandView: UIViewControllerRepresentable {
    private var brand: Brand?

    init(_ brand: Brand? = nil) {
        self.brand = brand
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = BrandViewController()
        if let brand {
            viewController.link = .merchantLocations(brand.slug)
        }
        return UINavigationController(rootViewController: viewController)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}
