//
//  SpendToolbar.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 9/22/25.
//  Copyright © 2025 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore

struct SpendToolbar: ToolbarContent {
    @Environment(\.openURL) private var openURL
    var closeAction: (() -> Void)?

    init(_ closeAction: (() -> Void)?) {
        self.closeAction = closeAction
    }

    var body: some ToolbarContent {
        if Flexa.supportsGlass {
            ToolbarItem(placement: .topBarLeading) {
                FlexaRoundedButton(.close, buttonAction: { closeAction?() })
            }
            ToolbarItemGroup {
                FlexaRoundedButton(.find) {
                    if let url = FlexaLink.merchantList.url {
                        openURL(url)
                    }
                }
                NavigationMenu {
                    FlexaRoundedButton(.settings)
                }
            }
        } else {
            ToolbarItem(placement: .navigationBarTrailing) {
#if FX_SUPPORTS_GLASS
                if #available (iOS 26.0, *), Flexa.supportsGlass {
                    legacyToolbarItem.glassEffect(.identity)
                } else {
                    legacyToolbarItem
                }
#else
                legacyToolbarItem
#endif
            }
        }
    }

    @ViewBuilder
    private var legacyToolbarItem: some View {
        HStack(spacing: 8) {
            NavigationMenu {
                FlexaRoundedButton(.settings)
            }
            FlexaRoundedButton(.close, buttonAction: { closeAction?() })
        }
    }
}

#Preview {
    NavigationView {
        Color.purple.ignoresSafeArea()
            .toolbar {
                SpendToolbar(nil)
            }
    }
}
