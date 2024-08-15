//
//  ViewModelsInjection+Core.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/3/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory

extension Container {
    var authMainViewModel: Factory<AuthMainView.ViewModel> {
        self { AuthMainView.ViewModel() }
    }
}
