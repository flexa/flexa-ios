//
//  Synchronized.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/22/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

@propertyWrapper
public class Synchronized<T> {
    private var value: T
    private let lock = NSLock()

    public init(wrappedValue: T) {
        self.value = wrappedValue
    }

    public var wrappedValue: T {
        get {
            lock.withLock { value }
        }
        set {
            lock.withLock { value = newValue }
        }
    }
}
