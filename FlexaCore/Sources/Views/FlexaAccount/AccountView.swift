//
//  AccountView.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 7/30/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI
import Factory
import FlexaUICore

struct AccountView: View {
    typealias Strings = CoreStrings.Account
    @Environment(\.dismiss) var dismiss
    @Environment(\.dismissAll) var dismissAll
    @StateObject var viewModel = ViewModel()
    @State var showSignOutAlert = false
    @Injected(\.universalLinkData) var linkData

    @State var isShowingAccountData: Bool = false
    private let circleColor = Color(hex: "#76787C")

    private var arrowsImageName: String {
        if #available(iOS 17, *) {
            return "arrow.down.left.arrow.up.right"
        }
        return "arrow.left.arrow.right"
    }

    private var arrowsImageRotationAngle: Double {
        if #available(iOS 17, *) {
            return 0
        }
        return -45
    }

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    headerSection
                    limitSection
                    privacySection
                    signOutSection
                }
                navigationLinks
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
                    Button(CoreStrings.Global.cancel, role: .cancel) { }
                    Button(Strings.Alerts.SignOut.Buttons.SignOut.title, role: .destructive) {
                        viewModel.signOut()
                        Flexa.close()
                    }
                } message: {
                    Text(Strings.Alerts.SignOut.message(viewModel.applicationName))
                }
                .onAppear(perform: load)
        }.tint(.flexaTintColor)
            .dragIndicator(true)
            .errorAlert(error: $viewModel.error)
    }

    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .center) {
            ZStack {
                headerSectionCircle.frame(width: 90, height: 90)
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
            Circle().fill(circleColor)
        }
    }

    private var limitSection: some View {
        Section {
            ForEach($viewModel.limits, id: \.id) { limit in
                let limitValue = limit.wrappedValue
                HStack(spacing: 16) {
                    CircularProgressView.gauge(progress: limitValue.remainingPercentage) {
                        Image(systemName: arrowsImageName)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .font(.body.weight(.heavy))
                            .foregroundStyle(Color.flexaTintColor)
                            .rotationEffect(.degrees(arrowsImageRotationAngle))
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

    private var navigationLinks: some View {
        NavigationLink(
            destination:
                DataAndPrivacyView(viewModel: DataAndPrivacyView.ViewModel()),
            isActive: $isShowingAccountData) {
        }.hidden()
    }

    private func load() {
        viewModel.loadAccount()
        switch linkData.url?.flexaLink {
        case .accountData:
            showAccountData()
            linkData.clear()
        case .accountDeletion:
            showAccountData()
        default:
            break
        }
    }

    @MainActor
    private func showAccountData() {
        var transaction = SwiftUICore.Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            isShowingAccountData = true
        }
    }
}
