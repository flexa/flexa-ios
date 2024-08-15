//
//  EventModel.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 6/13/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import SwiftUI

extension Models {
    struct Event<DataType: FlexaModelProtocol>: FlexaModelProtocol {
        var id: String
        var data: DataType
        var type: String
    }
}
