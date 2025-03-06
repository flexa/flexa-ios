//
//  FlexaView.swift
//  Flexa SDK
//
//  Created by Rodrigo Ordeix on 4/17/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI
import FlexaSpend
import FlexaUICore
import Factory

struct FlexaView<ScanView: View, PaymentView: View>: View {
    @State private var selection: String = "home"
    @State private var tabSelection: TabBarItem = .scan

    @StateObject var modalState = SpendModalState()
    @StateObject var linkData: UniversalLinkData = Container.shared.universalLinkData()
    @Injected(\.flexaClient) var flexaClient
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    private var scanContent: (() -> ScanView)?
    private var payContent: (() -> PaymentView)?

    init(scanContent: (() -> ScanView)? = nil, payContent: (() -> PaymentView)? = nil) {
        self.scanContent = scanContent
        self.payContent = payContent
    }

    public var body: some View {
        Group {
            if let payContent, let scanContent {
                CustomTabBarContainerView(selection: $tabSelection) {
                    VStack(alignment: .center, spacing: 16) {
                        scanContent()
                    }.tabBarItem(tab: .scan, selection: $tabSelection)
                    VStack(alignment: .center, spacing: 16) {
                        payContent()
                    }.tabBarItem(tab: .spend, selection: $tabSelection)
                }
            } else if let payContent {
                payContent()
            } else if let scanContent {
                scanContent()
            } else {
                EmptyView()
            }
        }.environment(\.colorScheme, flexaClient.theme.interfaceStyle.colorSheme ?? colorScheme)
            .environmentObject(modalState)
            .flexaHandleUniversalLink()
            .environmentObject(linkData)
            .environment(\.dismissAll, dismiss)
            .theme(flexaClient.theme)
    }
}
