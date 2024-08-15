//
//  AccountView.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 7/30/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI
import FlexaUICore

struct AccountView: View {
    typealias Strings = L10n.Account
    @Environment(\.dismiss) var dismiss
    @Environment(\.dismissAll) var dismissAll
    @StateObject var viewModel: ViewModel
    @State var showSignOutAlert = false

    private let circleColor = Color(hex: "#76787C")

    var body: some View {
        NavigationView {
            List {
                headerSection
                limitSection
                privacySection
                signOutSection
            }.environment(\.defaultMinListRowHeight, 56)
                .navigationTitle(Strings.Navigation.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) { Color.clear }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        FlexaRoundedButton(.close, buttonAction: { dismiss() })
                    }
                }
                .alert(Strings.Alerts.SignOut.title, isPresented: $showSignOutAlert) {
                    Button(L10n.Common.cancel, role: .cancel) { }
                    Button(Strings.Alerts.SignOut.Buttons.SignOut.title, role: .destructive) {
                        viewModel.signOut()
                        dismissAll?()
                    }
                } message: {
                    Text(Strings.Alerts.SignOut.message(viewModel.applicationName))
                }
        }.tint(.purple)
            .dragIndicator(true)
            .onAppear(perform: viewModel.loadAccount)
            .errorAlert(error: $viewModel.error)
    }

    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .center) {
            ZStack {
                headerSectionCircle.frame(width: 90)
                Text(viewModel.nameInitials)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
            }

            Text(viewModel.fullName).font(.title.bold())
            Text(viewModel.joinedIn).foregroundStyle(Color.secondary)
        }.frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
    }

    @ViewBuilder
    private var headerSectionCircle: some View {
        if #available(iOS 16.0, *) {
            Circle()
                .fill(circleColor.gradient)
        } else {
            Circle().foregroundStyle(circleColor)
        }
    }

    private var limitSection: some View {
        Section {
            ForEach($viewModel.limits, id: \.id) { limit in
                let limitValue = limit.wrappedValue
                HStack(spacing: 16) {
                    CircularProgressView.gauge(progress: limitValue.remainingPercentage) {
                        Image(systemName: "arrow.down.left.arrow.up.right")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .font(.body.weight(.heavy))
                            .foregroundStyle(.purple)
                    }
                    .frame(width: 40)
                    .offset(y: 4)
                    VStack(alignment: .leading) {
                        HStack {
                            Text(limitValue.title).fontWeight(.semibold)
                            Spacer()
                            Text(limitValue.amountPerWeek)
                                .foregroundStyle(Color.secondary)
                        }
                        Text(limitValue.remainingAmount)
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                }.padding(.vertical, 4)
            }
        } header: {
            Text(Strings.Sections.Limit.Header.title)
        } footer: {
            Text(viewModel.limitResetsAt)
        }
    }

    private var privacySection: some View {
        Section {
            NavigationLink(
                Strings.Sections.DataAndPrivacy.Cells.DataAndPrivacy.title,
                destination:
                    DataAndPrivacyView(viewModel: DataAndPrivacyView.ViewModel())
            )
        }
    }

    private var signOutSection: some View {
        Section {
            Button(role: .destructive) {
                showSignOutAlert = true
            } label: {
                Text(Strings.Sections.SignOut.Cells.SignOut.title)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var closeButton: some View {
        HStack(alignment: .top) {
            Spacer()
            FlexaRoundedButton(.close) {
                dismiss()
            }.padding()
        }.frame(maxWidth: .infinity)
    }
}

#Preview {
    AccountView(viewModel: AccountView.ViewModel())
}
