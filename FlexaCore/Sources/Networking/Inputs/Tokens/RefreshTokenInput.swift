//
//  RefreshTokenInput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/9/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import UIKit

struct RefreshTokenInput: FlexaModelProtocol, LogExcludedProtocol {
    var verifier: String
    var challenge: String

    static func == (lhs: RefreshTokenInput, rhs: RefreshTokenInput) -> Bool {
        lhs.verifier == rhs.verifier &&
        lhs.challenge == rhs.challenge
    }
}
