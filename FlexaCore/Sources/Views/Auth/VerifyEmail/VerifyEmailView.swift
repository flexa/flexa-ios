//
//  VerifyEmailView.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/6/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

struct VerifyEmailView: View {
    typealias Strings = CoreStrings.Auth.VerifyEmail

    @Environment(\.theme.tables.cell) var theme
    @StateObject var viewModel: ViewModel
    @State private var goNext = false

    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .center, spacing: 12) {
                header.padding(.horizontal, 40)
                ZStack {
                    list.padding(.horizontal, 40)
                    footer
                }
                Spacer()
            }
        }
        .onBackground {
            goNext = true
        }
        .background(.thinMaterial)
        .tint(nil)
        .ignoresSafeArea(.all, edges: .bottom)
        .navigationBarTitleDisplayMode(.inline)

    }

    @ViewBuilder
    private var header: some View {
        Image(systemName: "envelope.badge")
            .font(.system(size: 48, weight: .bold))
            .foregroundStyle(Color.purple)
            .frame(width: 68)
            .padding(.vertical)
        Text(viewModel.headerTitle)
            .font(.largeTitle.bold())
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
        Text(viewModel.headerSubtitle)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
    }

    private var list: some View {
        List {
            Section {
                HStack(spacing: 0) {
                    Text("").frame(width: 0) // Make the separator start from the leading, even in iOS 15
                    AngularGradient(colors: [.white, Color(hex: "#7916EF")], center: .center, angle: .degrees(180))
                        .mask(
                            Circle()
                        )
                        .frame(width: 40, height: 40)
                        .padding(.vertical, 10)
                    VStack(alignment: .leading) {
                        Text(Strings.Table.Rows.Email.company)
                            .font(.subheadline.weight(.semibold))
                        Text(Strings.Table.Rows.Email.to)
                            .foregroundColor(Color.primary.opacity(0.4))
                            .font(.subheadline) +
                        Text(verbatim: viewModel.emailAddress)
                            .font(.subheadline)
                            .foregroundColor(.primary)

                    }.padding(.leading, 10)
                }.listRowBackground(
                    Rectangle()
                        .fill(theme.backgroundColor)
                        .cornerRadius(6, corners: [.topLeft, .topRight])
                )
                Text(viewModel.bottomTitle)
                    .font(.system(size: 18, weight: .bold))
                    .listRowSeparator(.hidden, edges: .bottom)
                    .padding(.bottom, 38)
                    .listRowBackground(
                        theme.backgroundColor
                    )

            }
        }.listStyle(PlainListStyle())
            .simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
            .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 2)
            .padding(.top, 30)
    }

    private var footer: some View {
        VStack(spacing: 28) {
            Spacer()
            Button {
                viewModel.openMail()
            } label: {
                Text(Strings.Buttons.OpenEmail.title)
                    .flexaButton()
            }.padding(.horizontal, 24)
                .padding(.bottom, 58)
            NavigationLink(
                destination: MagicCodeView(viewModel: MagicCodeView.ViewModel()),
                isActive: $goNext
            ) {
            }
        }
        .background(.thinMaterial)
        .overlay(Divider().background(Color(UIColor.systemGray3)), alignment: .top)
            .padding(.top, 170)
    }
}

#Preview {
    VerifyEmailView(viewModel: VerifyEmailView.ViewModel(emailAddress: "john.doe@example.com"))
}
