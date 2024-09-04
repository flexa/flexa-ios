//
//  CreateTokenInput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/9/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import UIKit

struct CreateTokenInput: FlexaModelProtocol, LogExcludedProtocol {
    enum CodingKeys: String, CodingKey {
        case email, challenge
        case deviceId = "device_id"
        case deviceModel = "device_model"
    }

    var email: String
    var deviceId: String
    var deviceModel: String
    var challenge: String

    init(email: String,
         challenge: String,
         deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? "",
         deviceModel: String = UIDevice.current.model) {
        self.email = email
        self.challenge = challenge
        self.deviceId = deviceId
        self.deviceModel = deviceModel
    }

    static func == (lhs: CreateTokenInput, rhs: CreateTokenInput) -> Bool {
        lhs.email == rhs.email &&
        lhs.deviceId == rhs.deviceId &&
        lhs.deviceModel == rhs.deviceModel &&
        lhs.challenge == rhs.challenge
    }
}
