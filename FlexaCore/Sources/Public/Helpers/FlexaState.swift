//
//  FlexaState.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 8/30/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI
import Factory

public class FlexaState: ObservableObject {
    @Injected(\.userDefaults) private var userDefaults

    @Published public var isModalVisible: Bool = false
    @Published public var isPayWithFlexaEnabled: Bool = false {
        didSet {
            userDefaults.setValue(isPayWithFlexaEnabled, forKey: .payWithFlexaEnabled)
        }
    }

    public init() {
        reset()
    }

    public func reset() {
        isModalVisible = false
        let val: Bool? = userDefaults.value(forKey: .payWithFlexaEnabled)
        isPayWithFlexaEnabled = userDefaults.value(forKey: .payWithFlexaEnabled) ?? true
    }
}
