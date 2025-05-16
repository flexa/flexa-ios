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
    var authMainViewModel: ParameterFactory<(Bool), AuthMainView.ViewModel> {
        self { allowToDisablePayWithFlexa in
            AuthMainView.ViewModel(allowToDisablePayWithFlexa: allowToDisablePayWithFlexa)
        }
    }

    var commerceSessionViewModel: ParameterFactory<(Flexa.TransactionRequestCallback?),
                                                    CommerceSessionView.ViewModel> {
        self { signTransaction in
            CommerceSessionView.ViewModel(signTransaction: signTransaction)
        }
    }
}
