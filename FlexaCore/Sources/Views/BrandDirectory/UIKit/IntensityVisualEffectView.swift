//
//  IntensityVisualEffectView.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 8/11/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import UIKit

final class IntensityVisualEffectView: UIVisualEffectView {
  private var intensityEffect: UIVisualEffect
  private var intensity: CGFloat
  private var animator: UIViewPropertyAnimator?

  init(effect: UIVisualEffect, intensity: CGFloat) {
    intensityEffect = effect
    self.intensity = intensity
    super.init(effect: nil)
  }

  required init?(coder aDecoder: NSCoder) { nil }

  deinit {
    animator?.stopAnimation(true)
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    effect = nil
    animator?.stopAnimation(true)
    animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
      self.effect = intensityEffect
    }
    animator?.fractionComplete = intensity
  }

  func setEffect(_ effect: UIVisualEffect) {
    intensityEffect = effect
    setNeedsDisplay()
  }

  func setIntensity(_ intensity: CGFloat) {
    self.intensity = intensity
    setNeedsDisplay()
  }
}
