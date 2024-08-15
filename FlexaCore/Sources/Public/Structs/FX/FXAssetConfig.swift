//
//  FXAssetConfig.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/18/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation

public class FXAssetConfig: ObservableObject {
    @Published public var selectedAssetId: String
    @Published public var selectedAppAccountId: String

    public init(selectedAssetId: String = "",
                selectedAccountId: String = "") {
        self.selectedAssetId = selectedAssetId
        self.selectedAppAccountId = selectedAccountId
    }
}
