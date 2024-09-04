//
//  Asset.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/20/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import SwiftUI

public protocol Asset {
    var id: String { get }
    var symbol: String { get }
    var color: Color? { get }
    var iconUrl: URL? { get }
    var displayName: String { get }
    var livemode: Bool { get }
}
