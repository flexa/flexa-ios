//
//  HelpersInjection.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/12/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory
import KeychainAccess

public extension Container {
    var appStateManager: Factory<AppStateManagerProtocol> {
        self { AppStateManager() }.singleton
    }
}
