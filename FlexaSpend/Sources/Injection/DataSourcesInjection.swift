//
//  DataSourcesInjection.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 12/12/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import FlexaCore
import Factory

extension Container {
    var userDefaults: Factory<UserDefaults> {
        self { UserDefaults.flexaStore }.singleton
    }
}
