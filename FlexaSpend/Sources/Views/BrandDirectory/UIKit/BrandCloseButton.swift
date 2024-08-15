//
//  BrandCloseButton.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 8/11/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import UIKit

class BrandCloseButton: UIButton {
    enum DisplayMode {
        case floating, overHiddenNavbar, overNavbar
    }

    private let buttonSize: CGFloat = 30
    private let buttonImage = UIImage(
        systemName: "xmark",
        withConfiguration: UIImage.SymbolConfiguration(
            pointSize: 20,
            weight: .bold,
            scale: .medium
        )
    )?.withRenderingMode(.alwaysTemplate)

    private var displayMode: DisplayMode = .floating

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func setDisplayMode(_ displayMode: DisplayMode, animated: Bool = false, animationDuration: CGFloat = 0.2, delay: CGFloat = 0) {

        guard animated, self.displayMode != displayMode else {
            self.displayMode = displayMode
            updateColors()
            return
        }

        self.displayMode = displayMode
        UIView.animate(withDuration: animationDuration, delay: delay) {
            self.updateColors()
        }
    }

    private func commonInit() {
        setImage(buttonImage, for: .normal)
        layer.cornerRadius = buttonSize / 2
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        translatesAutoresizingMaskIntoConstraints = false

    }

    private func updateColors() {
        if displayMode == .overHiddenNavbar {
            tintColor = Asset.brandDirectoryCloseButtonFloatingTint.color
            backgroundColor = .black.withAlphaComponent(0.1)
            return
        }

        tintColor = UIColor.secondaryLabel
        backgroundColor = UIColor.tertiarySystemFill.withAlphaComponent(0.16)
    }
}
