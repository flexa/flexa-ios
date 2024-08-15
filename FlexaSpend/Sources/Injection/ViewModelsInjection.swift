//
//  NetworkAssembly.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 12/12/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import Factory
import FlexaCore

extension Container {
    var spendViewViewModel: ParameterFactory<Flexa.TransactionRequestCallback?, SpendView.ViewModel> {
        self { signTransaction in
            SpendView.ViewModel(signTransaction: signTransaction)
        }
    }

    var noAssetsViewModel: ParameterFactory<[FXAvailableAsset], NoAssetsView.ViewModel> {
        self { invalidAssets in
            NoAssetsView.ViewModel(invalidAssets)
        }
    }

    var legacyFlexcodeListViewModel: Factory<LegacyFlexcodeList.ViewModel> {
        self { LegacyFlexcodeList.ViewModel() }
    }

    var merchantSorterViewModel: Factory<MerchantSorter.ViewModel> {
        self { MerchantSorter.ViewModel() }
    }
}
