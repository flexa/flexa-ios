//
//  UniversalLinkData.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 05/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public class UniversalLinkData: ObservableObject {
    @Published public var url: URL?

    public init(url: URL? = nil) {
        self.url = url
    }

    public func clear() {
        url = nil
    }
}
