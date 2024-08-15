//
//  DestinationModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/20/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

extension Models {
    struct Destination: FlexaModelProtocol {
        var address: String
        var label: String

        init(address: String, label: String) {
            self.address = address
            self.label = label
        }
    }
}

extension Models.Destination: Destination {
}
