//
//  RefreshAppAccountsOutput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

struct RefreshAppAccountsOutput: FlexaModelProtocol {
    let data: [Models.AppAccount]

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decodeIfPresent([Models.AppAccount].self, forKey: .data) ?? []
    }
}
