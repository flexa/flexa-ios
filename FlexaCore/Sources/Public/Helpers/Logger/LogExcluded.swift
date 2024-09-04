//
//  LogExcluded.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 08/28/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

@propertyWrapper
public struct LogExcluded<T: Codable>: LogExcludedProtocol, Codable {
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try container.decode(T.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}
