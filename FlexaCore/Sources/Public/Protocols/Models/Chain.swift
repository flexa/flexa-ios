//
//  Chain.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/11/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public protocol Chain {
    var id: String { get }
    var displayName: String? { get }
    var namespace: String? { get }
    var nativeAsset: String? { get }
    var network: String? { get }
    var testNetwork: Bool { get }
}
