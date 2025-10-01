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
    @EnvironmentObject var linkData: UniversalLinkData

    public var didSelect: Closure?

    private var titleFont: Font {
        if #available(iOS 26.0, *) {
            return .title2.weight(.semibold)
        }
        return .subheadline.weight(.semibold)
    }

    private var editButtonFont: Font {
        if #available(iOS 26.0, *) {
            return .subheadline.weight(.semibold)
        }
        return .subheadline
    }

    init(didSelect: Closure? = nil) {
        self.didSelect = didSelect
    }

    var placeholderView: some View {
        RoundedRectangle(cornerRadius: .brandLogoCornerRadius)
            .fill(Color.gray)
            .frame(width: .brandLogoSize, height: .brandLogoSize)
    }

    @ViewBuilder
    private var editButtonBackground: some View {
        if #available(iOS 26.0, *) {
            Capsule()
                .foregroundStyle(Color(UIColor.tertiarySystemFill))
                .frame(width: 50, height: 30)
        } else {
            Color.clear
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text(L10n.LegacyFlexcodeTray.title)
                    .font(titleFont)
                    .padding(.leading, .titleLeadingPadding)
                Spacer()
                Button {
                    showMerchantSorter = true
                } label: {
                    Text(L10n.LegacyFlexcodeTray.EditButton.title)
                        .font(editButtonFont)
                        .foregroundColor(.flexaTintColor)
                        .background(editButtonBackground)
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
        }.onChange(of: linkData.url) { url in
            if case .pinnedBrands = url?.flexaLink {
                showMerchantSorter = true
                linkData.url = nil
            }
        }
    }
}

// MARK: Theming
private extension LegacyFlexcodeList {
    var listCornerRadius: CGFloat {
        if #available(iOS 26.0, *) {
            return 0
        }
        return theme.containers.content.borderRadius
    }

    var backgroundColor: Color {
        if #available(iOS 26.0, *) {
            return .clear
        }
        return theme.containers.content.backgroundColor
    }
}

private extension CGFloat {
    static let listVerticalPadding: CGFloat = 20
    static let listItemSpacing: CGFloat = 10
    static let brandNameSize: CGFloat = 66
    static let editButtonTrailingPadding: CGFloat = 32
    static var titleLeadingPadding: CGFloat {
        if #available(iOS 26.0, *) {
            return 24
        }
        return 8
    }
    static var viewHeight: CGFloat {
        if #available(iOS 26.0, *) {
            return 100
        }
        return 140
    }
    static var listHorizontalPadding: CGFloat {
        if #available(iOS 26.0, *) {
            return titleLeadingPadding
        }
        return 22
    }
    static var brandLogoSize: CGFloat {
        if #available(iOS 26.0, *) {
            return 68
        }
        return 54
    }
    static var brandLogoCornerRadius: CGFloat {
        if #available(iOS 26.0, *) {
            return 14
        }
        return 6
    }
    static var listSpacing: CGFloat {
        if #available(iOS 26.0, *) {
            return 12
        }
        return 20
    }
}
