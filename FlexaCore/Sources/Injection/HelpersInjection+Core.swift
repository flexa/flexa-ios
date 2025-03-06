//
//  HelpersInjection+Core.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory
import KeychainAccess

extension Container {
    var pkceHelper: Factory<PKCEHelperProtocol> {
        self { PKCEHelper() }.singleton
    }

    var flexaNotificationCenter: Factory<NotificationCenter> {
        self { NotificationCenter() }.singleton
    }

    var keychainHelper: Factory<KeychainHelperProtocol> {
        self { KeychainHelper() }.singleton
    }

    var assetsHelper: Factory<AssetHelperProtocol> {
        self { AssetHelper() }.singleton
    }
}
