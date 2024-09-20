//
//  AssetsRepositoryProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 3/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory
import SwiftUI

public protocol AssetsRepositoryProtocol {
    var assets: [Asset] { get }

    @discardableResult
    func refresh() async throws -> [Asset]
    func backgroundRefresh()
}
