//
//  DisimissAll.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/29/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

public struct DismissAllKey: EnvironmentKey {
    public static let defaultValue: DismissAction? = nil
}

public extension EnvironmentValues {
    var dismissAll: DismissAction? {
        get { self[DismissAllKey.self] }
        set { self[DismissAllKey.self] = newValue }
    }
}
