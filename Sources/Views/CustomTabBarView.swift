//
//  CustomTabBarView.swift
//  Flexa SDK
//
//  Created by Rodrigo Ordeix on 4/17/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI
import Factory

struct CustomTabBarView: View {
    let tabs: [TabBarItem]
    @Binding var selection: TabBarItem
    @Namespace private var namespace
    @EnvironmentObject var linkData: UniversalLinkData
    @State private var connectResult: ConnectResult = .notConnected(nil)
    @State private var auth: FlexaIdentity!

    var body: some View {
        ZStack {
            HStack {
                ForEach(tabs, id: \.self) { tab in
                    tabView(tab: tab)
                        .onTapGesture {
                            switchToTab(tab: tab)
                        }
                }
            }
            .padding(1)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(Color.gray.opacity(0.6))
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 30)
        .onChange(of: linkData.url) { url in
            switch url?.flexaLink {
            case .scan:
                switchToTab(tab: .scan)
            case .pay, .pinnedBrands:
                switchToTab(tab: .spend)
            default:
                break
            }
        }
        .onAppear(perform: getConnectionState)
    }
}

extension CustomTabBarView {
    private func tabView(tab: TabBarItem) -> some View {
        VStack {
            Text(tab.title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
        }
        .foregroundColor(selection == tab ? .black : .white)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .background(
            ZStack {
                if selection == tab {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .matchedGeometryEffect(id: "background_rectangle", in: namespace)
                }
            }
        )
    }

    @MainActor
    private func switchToTab(tab: TabBarItem) {
        guard selection != tab else {
            return
        }

        if tab == .spend {
            switchToSpend()
        } else {
            sendComponentChangeNotification(tab)
            withAnimation(.easeIn) {
                selection = tab
            }
        }
    }

    private func sendComponentChangeNotification(_ tab: TabBarItem) {
        let notificationName: Notification.Name = {
            switch tab {
            case.scan:
                return .flexaComponentScanSelected
            case.load:
                return .flexaComponentLoadSelected
            case.spend:
                return .flexaComponentSpendSelected
            }
        }()

        Container.shared.eventNotifier().post(name: notificationName)
    }

    private func switchToSpend(_ animated: Bool = true) {
        guard case .connected = connectResult else {
            auth.open()
            return
        }
        sendComponentChangeNotification(.spend)
        if animated {
            withAnimation(.easeIn) {
                selection = .spend
            }
        } else {
            selection = .spend
        }
    }

    private func getConnectionState() {
        self.auth = Flexa
            .buildIdentity()
            .allowToDisablePayWithFlexa(true)
            .delayCallbacks(false)
            .onResult { result in
                DispatchQueue.main.async {
                    connectResult = result
                    if case .connected = result {
                        sendComponentChangeNotification(.spend)
                        switchToSpend(false)
                    }
                }
            }
            .build()
        auth.collect(handleConnectionStateChange)
    }

    private func handleConnectionStateChange(_ connectionResult: ConnectResult) {
        self.connectResult = connectionResult
    }
}
