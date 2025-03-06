//
//  UniversalLinkHandlerProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 11/12/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

public protocol UniversalLinkHandlerProtocol {
    // Handles universal links received by the parent application
    /// - parameter url: The url to be processed
    /// - returns: true if recongizes and is able to handle the url, and false otherwise
    static func processUniversalLink(url: URL) -> Bool
}

extension UniversalLinkHandlerProtocol {
    public static func processUniversalLink(url: URL) -> Bool {
        guard let link = url.flexaLink else {
            return false
        }
        Container.shared.universalLinkData().url = link.url
        return true
    }
}
