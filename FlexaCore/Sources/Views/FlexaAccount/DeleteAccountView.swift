//
//  DeleteAccountView.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 8/2/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI
import SwiftUIIntrospect

struct DeleteAccountView: View {
    typealias Strings = CoreStrings.DeleteAccount
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: ViewModel

    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ZStack(alignment: .top) {
                    ScrollView(.vertical) {
                        VStack(alignment: .center, spacing: 12) {
                            header
                                .padding(.horizontal, 20)
                            Spacer()
                            footer
                        }.frame(minHeight: proxy.size.height)
                            .padding(.horizontal, 24)
                    }
                }
            }
            .background(.thinMaterial)
            .tint(nil)
            .navigationBarTitleDisplayMode(.inline)
            .onError(error: $viewModel.error)
            .navigationBarBackButtonHidden(true)
        }
    }

    @ViewBuilder
    private var header: some View {
        Image(systemName: "person.fill.badge.minus")
            .font(.system(size: 48, weight: .bold))
            .symbolRenderingMode(.multicolor)
            .foregroundStyle(Color.flexaTintColor)
            .frame(width: 68)
            .padding(.top, 50)
            .offset(y: 10)
        Text(Strings.Header.title)
            .font(.largeTitle.bold())
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
        Text(Strings.Header.subtitle)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var footer: some View {
        VStack(spacing: 28) {
            Button {
                viewModel.deleteAccount()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .flexaButton()
                } else {
                    Text(Strings.Buttons.Next.title)
                        .flexaButton()
                }
            }
            Button {
                dismiss()
            } label: {
                Text(Strings.Buttons.Cancel.title)
                    .tint(.flexaTintColor)
                    .font(.body.weight(.semibold))
            }
        }.padding(.bottom, 20)
            .disabled(viewModel.isLoading)
        NavigationLink(
            destination: ConfirmAccountDeletionView(viewModel: ConfirmAccountDeletionView.ViewModel()),
            isActive: $viewModel.shouldGoVerifyEmail) {
        }
    }
}
