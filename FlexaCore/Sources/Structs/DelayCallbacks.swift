//
//  DelayCallbacks.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 4/9/25.
//

import SwiftUI

struct DelayCallbacksKey: EnvironmentKey {
    static var defaultValue: Bool = true
}

extension EnvironmentValues {
    var delayCallbacks: Bool {
        get { self[DelayCallbacksKey.self] }
        set { self[DelayCallbacksKey.self] = newValue }
    }
}

extension View {
    func delayCallbacks(_ value: Bool) -> some View {
        environment(\.delayCallbacks, value)
    }
}
