//
//  UIViewExtensions.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/14/25.
//  Copyright © 2024 Flexa. All rights reserved.
//

import UIKit

extension UIView {
    func pinToSuperview() {
        guard let parentView = superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            parentView.topAnchor.constraint(equalTo: topAnchor),
            parentView.leftAnchor.constraint(equalTo: leftAnchor),
            parentView.rightAnchor.constraint(equalTo: rightAnchor),
            parentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
