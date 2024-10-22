//
//  Price.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/20/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol Price: Value {
    var amount: String { get }
    var label: String { get }
    var priority: String? { get }
}
