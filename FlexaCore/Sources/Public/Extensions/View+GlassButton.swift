//
//  View+GlassButton.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/10/25.
//  Copyright © 2025 Flexa. All rights reserved.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func glassButtonStyle() -> some View {
#if FX_ENABLE_GLASS
        if #available(iOS 26.0, *), Flexa.supportsGlass {
            self.buttonStyle(.glass)
        } else {
            self
        }
#else
        self
#endif
    }
}
