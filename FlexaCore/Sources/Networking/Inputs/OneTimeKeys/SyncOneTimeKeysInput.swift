//
//  SyncOneTimeKeysInput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/2/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

struct SyncOneTimeKeysInput: FlexaModelProtocol {
    let data: [Asset]

    init(data: [Asset]) {
        self.data = data
    }

    init(assets: [String]) {
        self.data = assets.map(Asset.init)
    }
}

extension SyncOneTimeKeysInput {
    struct Asset: FlexaModelProtocol {
        let asset: String
    }
}
