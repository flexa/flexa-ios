//
//  MerchantSorter.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 9/26/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore
import Factory

struct MerchantSorter: View {
    private typealias Strings = L10n.MerchantSorter

    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Injected(\.flexaClient) var flexaClient
    @StateObject var viewModel = Container.shared.merchantSorterViewModel()

    var body: some View {
        NavigationView {
            List {
                header()
                Section(
                    header: sectionHeader(Strings.Sections.Pinned.Header.title),
                    footer: sectionFooter(
                        isEmpty: viewModel.pinnedBrands.isEmpty,
                        text: Strings.Sections.Pinned.Footer.title
                    )
                ) {
                    ForEach(viewModel.pinnedBrands, id: \.id) { brand in
                        Row(pinned: true, brand: brand, action: togglePinState)
                    }
                    .onMove(perform: movePinnedBrand)
                }

                Section(
                    header: sectionHeader(Strings.Sections.OtherBrands.Header.title),
                    footer: sectionFooter(
                        isEmpty: viewModel.otherBrands.isEmpty,
                        text: Strings.Sections.OtherBrands.Footer.title
                    )
                ) {
                    ForEach(viewModel.otherBrands, id: \.id) { brand in
                        Row(pinned: false, brand: brand, action: togglePinState)
                    }
                }
            }
            .environment(\.defaultMinListRowHeight, 50)
            .navigationTitle(Text(Strings.title))
            .toolbar {
                doneButton
            }
        }
        .environment(\.colorScheme, flexaClient.theme.interfaceStyle.colorSheme ?? colorScheme)
        .dragIndicator(true, backgroundColor: Color(UIColor.systemGroupedBackground))

    }

    @ViewBuilder func header() -> some View {
        Section(header: Text(Strings.description)
            .font(.callout)
            .foregroundColor(.secondary)
            .textCase(nil)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
        ) {
        }
    }

    @ViewBuilder func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .foregroundColor(.primary)
            .textCase(nil)
            .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
    }

    @ViewBuilder func sectionFooter(isEmpty: Bool, text: String) -> some View {
        if isEmpty {
            Text(text)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))

        } else {
            EmptyView()
        }
    }

    @ToolbarContentBuilder
    var doneButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            if Flexa.supportsGlass {
                FlexaRoundedButton(.checkmark) {
                    dismiss()
                }.tint(.flexaTintColor)
            } else {
                Button(action: {
                    dismiss()
                }, label: {
                    Text(L10n.Common.done)
                        .font(.headline)
                        .foregroundColor(.flexaTintColor)
                })
            }
        }
    }

    func movePinnedBrand(from source: IndexSet, to destination: Int) {
        viewModel.movePinnedBrand(from: source, to: destination)
    }

    func togglePinState(brand: Brand, pinned: Bool) {
        withAnimation {
            viewModel.togglePinState(brand: brand, pinned: pinned)
        }
    }
}
