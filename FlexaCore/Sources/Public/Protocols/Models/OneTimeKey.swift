//
//  OneTimeKey.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/2/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol OneTimeKey {
    var id: String { get }
    var asset: String { get }
    var expiresAt: Int { get }
    var length: Int { get }
    var livemode: Bool { get }
    var prefix: String { get }
    var secret: String { get }
    var isExpired: Bool { get }
    var serverTimeOffset: TimeInterval { get }
}
