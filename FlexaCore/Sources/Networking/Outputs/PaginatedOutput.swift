//
//  PaginOutput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

struct PaginatedOutput<T: FlexaModelProtocol>: FlexaModelProtocol {
    enum CodingKeys: String, CodingKey {
        case data
        case hasMore = "has_more"
    }

    var hasMore: Bool = true
    var data: [T]? = []
}
