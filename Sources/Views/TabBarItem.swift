//
//  TabBarItem.swift
//  Flexa SDK
//
//  Created by Rodrigo Ordeix on 4/17/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI

enum TabBarItem: Hashable {
    case scan, load, spend

    var title: String {
        switch self {
        case .scan:
            return "Scan"
        case .load:
            return "Load"
        case .spend:
            return "Pay"
        }
    }
}
