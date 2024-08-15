//
//  VerifyTokenInput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/28/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import UIKit

struct VerifyTokenInput: FlexaModelProtocol {
    let verifier: String
    let challenge: String
    let code: String?
    let link: String?
}
