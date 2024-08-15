//
//  ShakeModifier.swift
//  FlexaUICore
//
//  Created by Rodrigo Ordeix on 8/14/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

public extension View {
    func shake(_ shakes: Int) -> some View {
        modifier(ShakeEffect(shakes: shakes))
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 20
    var shakesPerUnit = 4
    var shakes: CGFloat

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    private var translation: CGFloat {
        amount * sin(shakes * .pi * CGFloat(shakesPerUnit))
    }

    init(shakes: Int) {
        self.shakes = CGFloat(shakes)
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: translation,
                y: 0
            )
        )
    }
}
