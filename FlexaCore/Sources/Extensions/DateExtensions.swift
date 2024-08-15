//
//  DateExtensions.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/15/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension Date {
    var apiFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
