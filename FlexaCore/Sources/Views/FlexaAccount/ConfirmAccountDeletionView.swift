//
//  ConfirmAccountDeletionView.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 8/2/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

struct ConfirmAccountDeletionView: View {
    typealias Strings = CoreStrings.ConfirmAccountDeletion

    @Environment(\.theme.tables.cell) var theme
    @StateObject var viewModel: ViewModel
    @State private var goNext = false

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                VStack(alignment: .center, spacing: 0) {
                    ScrollView {
                        VStack(alignment: .center, spacing: 0) {
                            header.padding(.horizontal, 40)
                            Spacer()
                            list.padding(.horizontal, 40)
                                .frame(height: 200)
                                .offset(y: 40)

                        }
                        .frame(minHeight: proxy.size.height * 0.8 - 52)
                    }
                    footer(mainViewHeigth: proxy.size.height)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
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
        Text(Strings.Header.title)
            .font(.largeTitle.bold())
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
        Text(Strings.Header.subtitle)
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
                Text(Strings.Table.Rows.Delete.title)
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
            .padding(.top, 24)
    }

    private func footer(mainViewHeigth: CGFloat) -> some View {
        ZStack(alignment: .center) {
            Button {
                viewModel.openMail()
            } label: {
                Text("Open Email")
                    .flexaButton()
            }
            .padding(.horizontal, 24)
            .padding(.top, mainViewHeigth * 0.09)
            .padding(.bottom, mainViewHeigth * 0.11)
        }
        .background(.thinMaterial)
        .overlay(Divider().background(Color(UIColor.systemGray3)), alignment: .top)
    }
}
