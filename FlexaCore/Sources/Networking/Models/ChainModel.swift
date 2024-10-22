//
//  ChainModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 11/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import SwiftUI

extension Models {
    struct Chain: FlexaModelProtocol {
        enum CodingKeys: String, CodingKey {
            case id, namespace, network
            case displayName = "display_name"
            case nativeAsset = "native_asset"
            case testNetwork = "test_network"
        }

        var id: String
        var displayName: String?
        var namespace: String?
        var nativeAsset: String?
        var network: String?
        var testNetwork: Bool
    }
}

extension Models.Chain: Chain {
}
