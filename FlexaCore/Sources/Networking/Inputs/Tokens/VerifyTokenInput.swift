//
//  VerifyTokenInput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/28/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import UIKit

struct VerifyTokenInput: FlexaModelProtocol, LogExcludedProtocol {
    var verifier: String
    var challenge: String
    var code: String?
    var link: String?

    static func == (lhs: VerifyTokenInput, rhs: VerifyTokenInput) -> Bool {
        lhs.verifier == rhs.verifier &&
        lhs.challenge == rhs.challenge &&
        lhs.code == rhs.code &&
        lhs.link == rhs.link
    }
}
