//
//  DataExtensions.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 6/6/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension Data {
    var utf8String: String {
        String(decoding: self, as: UTF8.self)
    }

    func split(with separator: [UInt8]) -> [Data] {
        if #available(iOS 16.0, *) {
            return split(separator: separator)
        }

        let dataSeparator = Data(separator)
        var splits: [Data] = []
        var searchRange: Range<Data.Index>
        var foundRange: Range<Data.Index>?

        while true {
            searchRange = (foundRange?.upperBound ?? startIndex)..<endIndex
            foundRange = range(of: dataSeparator, options: [], in: searchRange)

            if let foundRange = foundRange {
                splits.append(subdata(in: (searchRange.lowerBound..<foundRange.lowerBound)))
            } else {
                splits.append(subdata(in: searchRange))
                break
            }
        }

        return splits
    }
}
