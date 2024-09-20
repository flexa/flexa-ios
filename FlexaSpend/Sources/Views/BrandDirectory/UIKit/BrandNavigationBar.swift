//
//  BrandNavigationBar.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 8/11/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import UIKit

class BrandNavigationBar: UIView {
  private let initialIntensity: CGFloat = 0
  private let lightGrabberColor = UIColor.white.withAlphaComponent(0.1)
  private let darkGrabberColor = UIColor.black.withAlphaComponent(0.1)

  private var effectView: IntensityVisualEffectView!
  private var titleLabel: UILabel!
  private(set) var grabber: UIView!

  private var isDarkMode: Bool {
    self.traitCollection.userInterfaceStyle == .dark
  }

  private var blurEffectStyle: UIBlurEffect.Style {
    isDarkMode ? .systemMaterialDark : .systemMaterialLight
  }

  var title: String? {
    get {
      titleLabel.text
    }
    set {
      titleLabel.text = newValue
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
      super.traitCollectionDidChange(previousTraitCollection)
      updateForModeChange()
  }

  func updateIntensity(_ intensity: CGFloat) {
    effectView.setIntensity(intensity)

    UIView.animate(withDuration: 0.2) {
      if intensity < 0.3 {
        self.grabber.backgroundColor = self.lightGrabberColor
      } else if intensity > 0.5 {
        self.grabber.backgroundColor = self.darkGrabberColor
      }
    }

    titleLabel.alpha = intensity
  }

  private func commonInit() {
    translatesAutoresizingMaskIntoConstraints = false
    setupBlurEffect()
    setupTitleLabel()
    setupGrabber()
  }

  private func setupTitleLabel() {
    titleLabel = UILabel()
    titleLabel.alpha = initialIntensity
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    titleLabel.textAlignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(titleLabel)

    NSLayoutConstraint.activate([
      titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
      titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }

  private func setupGrabber() {
    grabber = UIView()
    grabber.translatesAutoresizingMaskIntoConstraints = false
    grabber.backgroundColor = lightGrabberColor
    grabber.layer.cornerRadius = 2.5
    grabber.clipsToBounds = true
    addSubview(grabber)

    NSLayoutConstraint.activate([
      grabber.widthAnchor.constraint(equalToConstant: 36),
      grabber.heightAnchor.constraint(equalToConstant: 5),
      grabber.topAnchor.constraint(equalTo: topAnchor, constant: 5),
      grabber.centerXAnchor.constraint(equalTo: centerXAnchor)
    ])
  }

  private func setupBlurEffect() {
    let effectView = IntensityVisualEffectView(
        effect: UIBlurEffect(style: blurEffectStyle),
        intensity: initialIntensity
    )
    effectView.translatesAutoresizingMaskIntoConstraints = false
    insertSubview(effectView, at: 0)
    self.effectView = effectView

    let attributes: [NSLayoutConstraint.Attribute] = [.left, .top, .right, .bottom]
    self.addConstraints(attributes.map { attribute in
        NSLayoutConstraint(
          item: effectView,
          attribute: attribute,
          relatedBy: .equal,
          toItem: self,
          attribute: attribute,
          multiplier: 1,
          constant: 0
        )
    })
  }

  private func updateForModeChange() {
      effectView.setEffect(UIBlurEffect(style: blurEffectStyle))
  }
}

extension UIView {
    func fadeIn(animated: Bool = true, withDuration duration: TimeInterval = 0.25) {
        guard animated else {
            self.alpha = 1
            return
        }

        UIView.animate(withDuration: duration) {
            self.alpha = 1
        }
    }

    func fadeOut(animated: Bool = true, withDuration duration: TimeInterval = 0.25) {
        guard animated else {
            self.alpha = 0
            return
        }
        UIView.animate(withDuration: duration) {
            self.alpha = 0
        }
    }
}
