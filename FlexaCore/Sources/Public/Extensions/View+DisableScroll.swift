//
//  View+DisableSroll.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 09/27/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func disableScroll() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollDisabled(true)
        } else {
            self
        }
    }
}
