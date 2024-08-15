//
//  RefreshTokenInput.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/9/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import UIKit

struct RefreshTokenInput: FlexaModelProtocol {
    let verifier: String
    let challenge: String
}
