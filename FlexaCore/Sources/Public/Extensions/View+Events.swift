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
    typealias NotificationHandler = () -> Void
    typealias NotificationHandlerWithParams = (_ notification: Notification) -> Void

    private var flexaNotificationCenter: NotificationCenter {
        Container.shared.flexaNotificationCenter()
    }

    func onBackground(_ perform: @escaping NotificationHandler) -> some View {
        onNotification(UIApplication.willResignActiveNotification, perform: perform)
    }

    func onForeground(_ perform: @escaping NotificationHandler) -> some View {
        onNotification(UIApplication.didBecomeActiveNotification, perform: perform)
    }

    func onAuthorizationError(_ perform: @escaping NotificationHandler) -> some View {
        onNotification(.flexaAuthorizationError, perform: perform, notificationCenter: flexaNotificationCenter)
    }

    func onTransactionSent(_ perform: @escaping NotificationHandler) -> some View {
        onNotification(.transactionSent, perform: perform, notificationCenter: flexaNotificationCenter)
    }

    func onPaymentLink(_ perform: @escaping (_: URL) -> Void) -> some View {
        onNotification(
            .paymentLinkDetected,
            perform: { notification in
                guard let url = notification.userInfo?.values.first as? URL,
                      case .paymentLink = url.flexaLink else {
                    return
                }
                perform(url)
            },
            notificationCenter: flexaNotificationCenter
        )
    }

    func onNotification(
        _ name: Notification.Name,
        perform: @escaping NotificationHandler,
        notificationCenter: NotificationCenter = .default) -> some View {
            self.onReceive(
                notificationCenter.publisher(for: name),
                perform: { _ in
                    perform()
                }
            )
        }

    func onNotification(
        _ name: Notification.Name,
        perform: @escaping NotificationHandlerWithParams,
        notificationCenter: NotificationCenter = .default) -> some View {
        self.onReceive(
            notificationCenter.publisher(for: name),
            perform: { notification in
                perform(notification)
            }
        )
    }
}
