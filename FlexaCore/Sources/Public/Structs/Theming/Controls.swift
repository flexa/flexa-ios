//
//  Controls.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/19/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public extension FXTheme {
    struct Controls: Codable {
    }
}

public extension FXTheme.Controls {
    struct Button: Codable {
    }

    struct LargeButton: Codable {
        var config: Button
    }

}
