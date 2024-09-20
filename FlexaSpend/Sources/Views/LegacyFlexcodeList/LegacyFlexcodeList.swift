//
//  LegacyFlexcodeTray.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 9/25/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI
import Foundation
import FlexaUICore
import Factory

struct LegacyFlexcodeList: View {
    public typealias Closure = (Brand) -> Void
    @StateObject var viewModel: ViewModel = Container.shared.legacyFlexcodeListViewModel()
    @State var showMerchantSorter: Bool = false
    @State var animate: Bool = false
    @Environment(\.theme) var theme

    public var didSelect: Closure?

    init(didSelect: Closure? = nil) {
        self.didSelect = didSelect
    }

    var placeholderView: some View {
        RoundedRectangle(cornerRadius: .brandLogoCornerRadius)
            .fill(Color.gray)
            .frame(width: .brandLogoSize, height: .brandLogoSize)
    }

    var body: some View {
        VStack {
            HStack {
                Text(L10n.LegacyFlexcodeTray.title)
                    .font(.subheadline.weight(.semibold))
                    .padding(.leading, .titleLeadingPadding)
                Spacer()
                Button {
                    showMerchantSorter = true
                } label: {
                    Text(L10n.LegacyFlexcodeTray.EditButton.title)
                        .font(.subheadline)
                        .foregroundColor(.purple)
                }.padding(.trailing, .editButtonTrailingPadding)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .center, spacing: .listSpacing) {
                    ForEach($viewModel.brands.wrappedValue, id: \.id) { brand in
                        VStack(alignment: .center, spacing: .listItemSpacing) {
                            RemoteImageView(
                                url: brand.logoUrl,
                                content: { image in
                                    image.resizable()
                                        .frame(width: .brandLogoSize, height: .brandLogoSize)
                                        .cornerRadius(.brandLogoCornerRadius)
                                        .aspectRatio(contentMode: .fill)
                                        .scaledToFit()
                                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                },
                                placeholder: {
                                    RoundedRectangle(cornerRadius: .brandLogoCornerRadius)
                                        .fill(Color.gray)
                                        .frame(width: .brandLogoSize, height: .brandLogoSize)
                                }
                            )
                            Text(brand.name)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .foregroundColor(.secondary)
                                .font(.footnote.weight(.semibold))
                                .frame(maxWidth: .brandNameSize, maxHeight: .infinity, alignment: .top)
                                .fixedSize(horizontal: false, vertical: true)
                        }.onTapGesture {
                            didSelect?(brand)
                        }
                    }.animation(animate ? .default : .none)
                }
                .padding(.horizontal, .listHorizontalPadding)
                    .padding(.vertical, .listVerticalPadding)
            }
            .frame(height: .viewHeight)
            .background(backgroundColor)
            .cornerRadius(listCornerRadius, corners: [.topLeft, .bottomLeft])
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showMerchantSorter) {
            MerchantSorter().onDisappear(perform: {
                animate = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    animate = false
                }
                viewModel.refreshBrands()
            })
        }.onAppear {
            viewModel.loadBrands()
        }
    }
}

// MARK: Theming
private extension LegacyFlexcodeList {
    var listCornerRadius: CGFloat {
        theme.containers.content.borderRadius
    }

    var backgroundColor: Color {
        theme.containers.content.backgroundColor
    }
}

private extension CGFloat {
    static let listHorizontalPadding: CGFloat = 22
    static let listVerticalPadding: CGFloat = 20
    static let listSpacing: CGFloat = 20
    static let listItemSpacing: CGFloat = 10
    static let brandLogoSize: CGFloat = 54
    static let brandNameSize: CGFloat = 66
    static let brandLogoCornerRadius: CGFloat = 6
    static let editButtonTrailingPadding: CGFloat = 32
    static let titleLeadingPadding: CGFloat = 8
    static let viewHeight: CGFloat = 140
}
