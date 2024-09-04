//
//  NotificationsList.swift
//  FlexasSpend
//
//  Created by Rodrigo Ordeix on 8/8/24.
//  Copyright © 2022 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore
import Factory

struct NotificationsList: View {
    @StateObject var viewModel: ViewModel
    @Environment(\.theme.views.primary) var theme

    private var padding: CGFloat {
        theme.padding ?? 24
    }

    private var notifications: [AppNotificationWrapper] {
        viewModel.notifications.map(AppNotificationWrapper.init)
    }

    private var showPageIndicator: Bool {
        notifications.count > 1
    }

    private var minHeight: CGFloat {
        showPageIndicator ? 200 : 160
    }

    private var contentPadding: CGFloat {
        showPageIndicator ? 40 : 0
    }

    var body: some View {
        if notifications.isEmpty {
            ZStack {
            }.frame(height: 4)
        } else {
            TabView {
                ForEach(notifications, id: \.id) { appNotification in
                    NotificationView(notification: appNotification.notification) {
                        withAnimation {
                            viewModel.deleteNotification(appNotification.id)
                        }
                    }.padding(.horizontal, padding)
                        .padding(.bottom, contentPadding)
                }
            }.tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                .tabViewPagerColors(defaultColor: .secondary.opacity(0.4), selectedColor: .secondary)
                .frame(minHeight: minHeight)
                .padding(.bottom, showPageIndicator ? 0 : 16)
        }
    }
}

private extension NotificationsList {
    struct AppNotificationWrapper: Hashable, Identifiable {
        var notification: AppNotification

        var id: String {
            notification.id
        }

        init(_ notification: AppNotification) {
            self.notification = notification
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: NotificationsList.AppNotificationWrapper, rhs: NotificationsList.AppNotificationWrapper) -> Bool {
            lhs.id == rhs.id
        }
    }
}
