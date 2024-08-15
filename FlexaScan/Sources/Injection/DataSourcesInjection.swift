//
//  DataSourcesInjection.swift
//  FlexaScan
//
//  Created by Rodrigo Ordeix on 12/26/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import Foundation
import Factory

public extension Container {
    var scanConfig: Factory<FlexaScan.Config> {
        self { .default }.singleton
    }
}
