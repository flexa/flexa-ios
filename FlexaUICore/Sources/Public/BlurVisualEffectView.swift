//
//  BlurVisualEffectView.swift
//  FlexaUICore
//
//  Created by Rodrigo Ordeix on 8/30/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI

public struct BlurVisualEffectView: UIViewRepresentable {
    public var effect: UIVisualEffect?
    public init(effect: UIVisualEffect? = nil) {
        self.effect = effect
    }
    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    public func updateUIView(_ uiView: UIVisualEffectView,
                             context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}
