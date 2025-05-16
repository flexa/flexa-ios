//
//  DataAndPrivacyView.swift
//  SwiftUIPlayground
//
//  Created by Rodrigo Ordeix on 7/30/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI
import Factory

struct DataAndPrivacyView: View {
    typealias Strings = CoreStrings.DataAndPrivacy
    @StateObject var viewModel: ViewModel
    @State var showDeleteAccountSheet: Bool = false
    @State var reload = false
    @Injected(\.universalLinkData) var linkData

    let headerGradientColors = [
        Color(hex: "#8C00FF"),
        Color(hex: "#5700FF")
    ]

    var body: some View {
        List {
            headerSection
            deleteAccountSection
            advancedSection
        }
        .environment(\.defaultMinListRowHeight, 56)
        .navigationTitle(Strings.Navigation.title)
        .navigationBarTitleDisplayMode(.inline)
        .tint(.flexaTintColor)
        .onChange(of: showDeleteAccountSheet) { _ in
            reload.toggle()
        }
        .onAppear(perform: load)
        .sheet(isPresented: $showDeleteAccountSheet) {
            DeleteAccountView(viewModel: DeleteAccountView.ViewModel())
        }
    }

    @ViewBuilder
    private var headerSection: some View {
        Section {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13)
                        .fill(
                            LinearGradient(
                                colors: headerGradientColors,
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    Image(systemName: "lock.fill")
                        .resizable()
                        .frame(width: 22, height: 30)
                        .foregroundStyle(Color.white)

                }.frame(width: 60, height: 60)
                Text(Strings.Sections.Header.title)
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)

                Text(.init(Strings.Sections.Header.description))
                    .font(.subheadline)
                    .tint(.flexaTintColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 26)

            }.frame(maxWidth: .infinity)
                .padding(.top, 26)
                .padding(.bottom, 6)
            VStack(spacing: 8) {
                Divider()
                    .padding(.leading, 20)
                    .padding(.vertical, 10)
                HStack {
                    Text(Strings.Sections.Header.accountEmail)
                    Spacer()
                    Text(viewModel.email).foregroundStyle(Color.secondary)
                }.padding(.horizontal, 20)
            }.listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 20, trailing: 0))
        }.listRowSeparator(.hidden)
    }

    private var deleteAccountSection: some View {
        Section {
            if !viewModel.isPendingDeletion {
                Button(role: .destructive) {
                    showDeleteAccountSheet = true
                } label: {
                    Text(Strings.Sections.DeleteAccount.Cells.deleteAccount)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HStack {
                    Image(systemName: "person.fill.badge.minus")
                        .symbolRenderingMode(.multicolor)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.flexaTintColor)
                        .frame(width: 44)
                    VStack(alignment: .leading) {
                        Text(Strings.Sections.DeleteAccount.Cells.DeletionPending.title)
                            .font(.body.weight(.semibold))
                        Text(Strings.Sections.DeleteAccount.Cells.DeletionPending.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }.padding(8)
            }
        }
    }

    private var advancedSection: some View {
        Section {
            HStack(spacing: 0) {
                Label(Strings.Sections.Advanced.Cells.sdkVersion, systemImage: "shippingbox")
                    .foregroundStyle(Color.primary)
                Spacer()
                Text(viewModel.sdkVersion)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text(Strings.Sections.Advanced.Header.title)
        }
    }

    @MainActor
    private func load() {
        switch linkData.url?.flexaLink {
        case .accountDeletion:
            showDeleteAccountSheet = true
            linkData.clear()
        default:
            break
        }
    }

}
