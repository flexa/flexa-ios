//
//  HelpersInjection.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 2/28/23.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import Factory

extension Container {
    var totpGenerator: ParameterFactory<(Data, Int), TOTPGeneratorProtocol> {
        self { data, digits in
            TOTPGenerator(secret: data, digits: digits)
        }
    }

    var flexcodeGenerator: Factory<FlexcodeGeneratorProtocol> {
        self { FlexcodeGenerator() }.singleton
    }

    var assetsHelper: Factory<AssetHelperProtocol> {
        self { AssetHelper() }.singleton
    }

    var urlRouter: Factory<URLRouterProtocol> {
        self { URLRouter() }
    }
}
