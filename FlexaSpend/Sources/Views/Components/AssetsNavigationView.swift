//
//  AssetsNavigationView.swift
//  FlexaSpend
//
//  Created by Marcelo Korjenioski on 8/24/23.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import SwiftUI

typealias UpdateAssetClosure = (AssetWrapper) -> Void

public struct AssetsNavigationView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.theme.views.sheet) var theme
    @Binding var showAssetsModal: Bool
    @StateObject private var viewModelAsset: AssetSelectionViewModel
    private var updateAsset: UpdateAssetClosure

    init(showAssetsModal: Binding<Bool>,
         viewModelAsset: StateObject<AssetSelectionViewModel>,
         updateAsset: @escaping UpdateAssetClosure) {
        _showAssetsModal = showAssetsModal
        _viewModelAsset = viewModelAsset
        self.updateAsset = updateAsset
    }

    public var body: some View {
        NavigationView {
            VStack {
                AssetSelectionView(showAssetsModal: $showAssetsModal,
                                   viewModel: _viewModelAsset,
                                   didSelect: handleSelection)
            }
            .navigationBarTitle(L10n.Payment.PayUsing.title, displayMode: .inline).background(theme.backgroundColor)
            .navigationBarItems(trailing:
                Button(action: {
                    showAssetsModal = false
                }, label: {
                    Text(L10n.Payment.done)
                        .foregroundColor(Color.purple)
                })
            )
        }
        .accentColor(.purple)
        .ignoresSafeArea()
    }

    private func handleSelection(selectedAsset: AssetWrapper) {
        updateAsset(selectedAsset)
        showAssetsModal = false
    }
}
