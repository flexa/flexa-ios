//
//  MagicCodeView.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

struct MagicCodeView: View {
    typealias Strings = CoreStrings.Auth.MagicCode

    @StateObject var viewModel: ViewModel
    @State var showingAlert: Bool = false
    @Environment(\.dismissAll) var dismissAll
    @Environment(\.loginResult) var loginResult
    @EnvironmentObject var linkData: UniversalLinkData

    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .center, spacing: 16) {
                header.padding(.horizontal, 40)
                MagicCodeInputView(code: $viewModel.code)
                    .frame(width: 300, height: 56)
                    .padding(.top, 14)
                    .disabled(viewModel.isLoading)
                if viewModel.isLoading {
                    HStack(spacing: 4) {
                        ProgressView()
                        Text(Strings.Loading.text)
                            .font(.body)
                            .foregroundStyle(Color.secondary)
                    }.padding(.top, 24)
                }
                Spacer()
                Button {
                    viewModel.endEditing()
                    showingAlert = true
                } label: {
                    Text(Strings.Links.NoCode.title)
                        .font(.subheadline)
                        .foregroundColor(Color.purple)
                }.padding(.bottom, 60)
                    .disabled(viewModel.isLoading)
                    .opacity(viewModel.isLoading ? 0.4 : 1)
            }
            alerts
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {

            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.thinMaterial)
                .onTapGesture(perform: viewModel.endEditing)
        )
        .tint(nil)
        .onChange(of: linkData.url) { url in
            viewModel.validateWithUrl(url)
            linkData.url = nil
        }.onChange(of: viewModel.validated) { value in
            if value {
                dismissAll?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    loginResult?(.connected)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var header: some View {
        Image(systemName: "lock.rotation")
            .font(.system(size: 48, weight: .bold))
            .foregroundStyle(Color.purple)
            .frame(width: 68, height: 58)
            .padding(.vertical)
        Text(Strings.Header.title)
            .multilineTextAlignment(.center)
            .font(.largeTitle.bold())
            .padding(.horizontal, 20)
            .lineLimit(2)
            .minimumScaleFactor(0.5)
    }

    @ViewBuilder
    private var alerts: some View {
        blankView()
            .errorAlert(error: $viewModel.error)

        blankView()
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(Strings.Alerts.NoCode.title),
                    message: Text(Strings.Alerts.NoCode.message),
                    dismissButton: .default(
                        Text(CoreStrings.Global.ok)
                    )
                )
            }
    }
}

#Preview {
    MagicCodeView(viewModel: MagicCodeView.ViewModel())
}
