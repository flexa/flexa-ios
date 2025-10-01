//
//  AssetsNavigationView.swift
//  FlexaCore
//
//  Created by Marcelo Korjenioski on 8/24/23.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation
import SwiftUI
import FlexaUICore

public typealias UpdateAssetClosure = (AssetWrapper) -> Void

public struct AssetsNavigationView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.theme.views.sheet) var theme
    @Binding var showAssetsModal: Bool
    @StateObject private var viewModelAsset: AssetSelectionViewModel
    private var updateAsset: UpdateAssetClosure

    private var listTopPadding: CGFloat {
        if #available(iOS 26.0, *) {
            return -20
        }
        return 0
    }

    public init(showAssetsModal: Binding<Bool>,
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
            .padding(.top, listTopPadding)
            .navigationBarTitle(CoreStrings.Payment.PayUsing.title, displayMode: .inline).background(theme.backgroundColor)
            .toolbar {
                doneButton
            }
        }
        .ignoresSafeArea()
    }

    @ToolbarContentBuilder
    var doneButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            if #available(iOS 26.0, *) {
                FlexaRoundedButton(.checkmark) {
                    showAssetsModal = false
                }.tint(.flexaTintColor)
            } else {
                Button(action: {
                    showAssetsModal = false
                }, label: {
                    Text(CoreStrings.Payment.done)
                        .font(.body.weight(.semibold))
                        .foregroundColor(.flexaTintColor)
                })
                .accentColor(.flexaTintColor)
            }
        }
    }

    private func handleSelection(selectedAsset: AssetWrapper) {
        updateAsset(selectedAsset)
        showAssetsModal = false
    }
}
