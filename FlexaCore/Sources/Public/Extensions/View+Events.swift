//
//  View+Events.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/13/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI
import Factory

public extension View {
    private var flexaNotificationCenter: NotificationCenter {
        Container.shared.flexaNotificationCenter()
    }

    func onBackground(_ perform: @escaping () -> Void) -> some View {
        onNotification(UIApplication.willResignActiveNotification, perform: perform)
    }

    func onForeground(_ perform: @escaping () -> Void) -> some View {
        onNotification(UIApplication.didBecomeActiveNotification, perform: perform)
    }

    func onAuthorizationError(_ perform: @escaping () -> Void) -> some View {
        onNotification(.flexaAuthorizationError, perform: perform, notificationCenter: flexaNotificationCenter)
    }

    func onNotification(
        _ name: Notification.Name,
        perform: @escaping () -> Void,
        notificationCenter: NotificationCenter = .default) -> some View {
        self.onReceive(
            notificationCenter.publisher(for: name),
            perform: { _ in perform() }
        )
    }
}
