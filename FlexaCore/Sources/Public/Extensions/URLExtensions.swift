//
//  URLExtensions.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 11/22/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import Factory

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

    var flexaLink: FlexaLink? {
        Container.shared.urlRouter().getLink(from: self)
    }

    func matches(regex: String) -> Bool {
        absoluteString.range(of: regex, options: .regularExpression) != nil
    }
}

public extension Array where Iterator.Element == URLQueryItem {
    subscript(_ key: String) -> String? {
        return first(where: { $0.name == key })?.value
    }
}
