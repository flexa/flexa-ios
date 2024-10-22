//
//  Brand.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/20/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import SwiftUI

public protocol Brand {
    var id: String { get }
    var color: Color? { get }
    var logoUrl: URL? { get }
    var name: String { get }
    var slug: String { get }
    var legacyFlexcodes: [BrandLegacyFlexcode]? { get }
    var promotions: [Promotion] { get }
}

public protocol BrandLegacyFlexcode {
    var asset: String { get }
    var amount: BrandLegacyFlexcodeAmount? { get }
}

public protocol BrandLegacyFlexcodeAmount {
    var min: String? { get }
    var max: String? { get }
}
