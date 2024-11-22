//
//  RestrictedRegionView.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 11/21/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

struct RestrictedRegionView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ZStack(alignment: .top) {
                    ScrollView(.vertical) {
                        VStack(alignment: .center, spacing: 12) {
                            Spacer().frame(height: 100)
                            header.padding(.horizontal, 20)
                            Spacer()
                            footer.padding(.horizontal, 6)
                        }.frame(minHeight: proxy.size.height)
                            .padding(.horizontal, 20)
                    }
                }
            }
            .background(.thinMaterial)
            .tint(nil)
            .dragIndicator(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }

    @ViewBuilder
    private var header: some View {
        Image(systemName: "nosign")
            .font(.system(size: 62, weight: .bold))
            .foregroundStyle(.gray)
            .frame(width: 74)
            .padding(.top, 50)
            .offset(y: 10)
            .padding(.bottom, 14)
        Text(CoreStrings.Auth.RestrictedRegion.Header.title)
            .font(.largeTitle.bold())
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
        Text(CoreStrings.Auth.RestrictedRegion.Header.subtitle)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
    }

    private var footer: some View {
        VStack(spacing: 28) {
            Button {
                dismiss()
            } label: {
                Text(CoreStrings.Global.ok)
                    .flexaButton()

            }.padding(.bottom, 58)
        }
    }
}
