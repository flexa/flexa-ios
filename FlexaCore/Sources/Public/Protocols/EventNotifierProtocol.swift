//
//  EventNotifierProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 9/6/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol EventNotifierProtocol {
    func post(name: Notification.Name, userInfo: [AnyHashable: Any])
    func addObserver(
        _ observer: Any,
        selector: Selector,
        name: Notification.Name)
    func removeObserver(_ observer: Any)
    func removeObserver(_ observer: Any, name: Notification.Name)
}

public extension EventNotifierProtocol {
    func post(name: Notification.Name) {
        post(name: name, userInfo: [:])
    }
}
