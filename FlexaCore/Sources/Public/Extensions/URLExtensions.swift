//
//  URLExtensions.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 11/22/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation

public extension URL {
    var components: URLComponents? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)
    }

    var queryItems: [URLQueryItem] {
        components?.queryItems ?? []
    }

    // Second Level Domain
    var sld: String {
        components?.host?.components(separatedBy: ".").suffix(2).joined(separator: ".") ?? ""
    }
}

public extension Array where Iterator.Element == URLQueryItem {
    subscript(_ key: String) -> String? {
        return first(where: { $0.name == key })?.value
    }
}
