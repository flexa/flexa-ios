//
//  Fee.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/20/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol Fee: Value {
    var asset: String { get }
    var equivalent: String { get }
    var price: Price { get }
}
