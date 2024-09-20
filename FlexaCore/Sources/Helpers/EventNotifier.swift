//
//  EventNotifier.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 9/6/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

struct EventNotifier: EventNotifierProtocol {
    @Injected(\.flexaNotificationCenter) var notificationCenter

    func post(name: Notification.Name, object: Any?) {
        notificationCenter.post(name: name, object: object)
    }

    func addObserver(_ observer: Any, selector: Selector, name: Notification.Name) {
        notificationCenter.addObserver(observer, selector: selector, name: name, object: nil)
    }

    func removeObserver(_ observer: Any) {
        notificationCenter.removeObserver(observer)
    }

    func removeObserver(_ observer: Any, name: Notification.Name) {
        notificationCenter.removeObserver(observer, name: name, object: nil)
    }
}
