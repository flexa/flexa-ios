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

    var eventNotifier: Factory<EventNotifierProtocol> {
        self { EventNotifier() }.singleton
    }

    var urlRouter: Factory<URLRouterProtocol> {
        self { URLRouter() }
    }

    var universalLinkData: Factory<UniversalLinkData> {
        self { UniversalLinkData() }.singleton
    }

    var flexaState: Factory<FlexaState> {
        self { FlexaState() }.singleton
    }

    var totpGenerator: ParameterFactory<(Data, Int), TOTPGeneratorProtocol> {
        self { data, digits in
            TOTPGenerator(secret: data, digits: digits)
        }
    }

    var flexcodeGenerator: Factory<FlexcodeGeneratorProtocol> {
        self { FlexcodeGenerator() }.singleton
    }
}
