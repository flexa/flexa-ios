//
//  NoAssetsView.swift
//  FlexaSpend
//
//  Created by Marcelo Korjenioski on 8/30/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI

extension NoAssetsView {
    class ViewModel: ObservableObject {
        @Published var invalidAssets: [FXAvailableAsset] = []

        init(_ invalidAssets: [FXAvailableAsset]) {
            self.invalidAssets = invalidAssets
        }

        var description: String {
            switch invalidAssets.count {
                case 0:
                    return Strings.Description.zeroAssets
                case 1:
                    return Strings.Description.oneInvalidAsset(invalidAssets[0].symbol)
                case 2:
                    return Strings.Description.twoInvalidAssets(invalidAssets[0].symbol, invalidAssets[1].symbol)
                default:
                    return Strings.Description.otherInvalidAssets(invalidAssets[0].symbol, invalidAssets[1].symbol)
            }
        }
    }
}

struct NoAssetsView: View {
    private typealias Strings = L10n.NoAssets
    @Environment(\.theme.containers.empty) var theme

    @StateObject var viewModel: ViewModel

    init(_ viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 4) {
                Text(Strings.title).font(.title2).bold()
                Text(viewModel.description)
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Button(action: {

                }, label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text(Strings.AddAssetButton.label)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(Color.flexaTintColor)
                    .foregroundColor(.flexaContrastTintColor)
                })
                .clipShape(Capsule())
                .padding(.top, 20)
            }.padding(.horizontal, padding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(0.88, contentMode: .fill)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
    }
}

// MARK: Theming
private extension NoAssetsView {
    var cornerRadius: CGFloat {
        theme.borderRadius
    }

    var padding: CGFloat? {
        theme.padding
    }

    var backgroundColor: Color {
        theme.backgroundColor
    }
}
