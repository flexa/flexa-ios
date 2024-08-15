//
//  HTTPURLResponseExtensions.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/20/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    var responseDate: Date? {
        guard let dateString = allHeaderFields["Date"] as? String else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz"
        return dateFormatter.date(from: dateString)
    }
}
