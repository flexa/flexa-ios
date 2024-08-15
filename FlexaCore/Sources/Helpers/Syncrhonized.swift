//
//  Synchronized.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/22/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

@propertyWrapper
class Synchronized<T> {
    private var value: T
    private let queue = DispatchQueue(label: "co.flexa.sdk", attributes: .concurrent)

    init(wrappedValue: T) {
        self.value = wrappedValue
    }

    var wrappedValue: T {
        get {
            queue.sync {
                return value
            }
        }
        set {
            queue.async(flags: .barrier) {
                self.value = newValue
            }
        }
    }
}
