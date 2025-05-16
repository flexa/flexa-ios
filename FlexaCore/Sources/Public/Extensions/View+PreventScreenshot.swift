//
//  View+PreventScreenshot.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/14/25.
//  Copyright © 2025 Flexa. All rights reserved.
//

import SwiftUI

public extension View {
    func preventScreenshot(backgroundColor: Color? = nil, @ViewBuilder _ replacement: () -> some View = { EmptyView() }) -> some View {
        ScreenshotPreventionView(backgroundColor: backgroundColor) {
            self
        }
        .background {
            replacement()
        }
    }
}
