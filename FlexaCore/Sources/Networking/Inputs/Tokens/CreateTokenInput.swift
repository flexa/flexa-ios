//
//  CreateTokenInput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/9/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import UIKit

struct CreateTokenInput: FlexaModelProtocol {
    enum CodingKeys: String, CodingKey {
        case email, challenge
        case deviceId = "device_id"
        case deviceModel = "device_model"
    }

    var email: String
    var challenge: String
    var deviceId: String
    var deviceModel: String

    init(email: String,
         challenge: String,
         deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? "",
         deviceModel: String = UIDevice.current.model) {
        self.email = email
        self.challenge = challenge
        self.deviceId = deviceId
        self.deviceModel = deviceModel
    }
}
