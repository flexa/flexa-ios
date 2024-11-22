//
//  AuthMainView.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/3/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI
import Factory

struct AuthMainView: View {
    private typealias Strings = CoreStrings.Auth.Main

    private let bottomViewId = UUID()

    @Environment(\.theme.views.primary) var theme
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isEmailFieldFocused: Bool

    @StateObject var viewModel: ViewModel = Container.shared.authMainViewModel()
    @State var bottomViewBottomPadding: CGFloat = .bottomViewBottomPaddingDefault
    @State private var showingPrivacyAlert: Bool = false

    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ZStack(alignment: .top) {
                    ScrollViewReader { scrollViewProxy in
                        ScrollView(.vertical) {
                            VStack(spacing: .mainSpacing) {
                                headerView
                                VStack(spacing: .mainSpacing) {
                                    titleView
                                    bulletsView
                                    Spacer()
                                    bottomView
                                        .padding(.bottom, bottomViewBottomPadding)
                                        .id(bottomViewId)
                                }.padding(.horizontal, .defaultPadding)
                            }.frame(minHeight: proxy.size.height)
                        }.onChange(of: isEmailFieldFocused) { isFocused in
                            handleFocusChange(isFocused, scrollViewProxy: scrollViewProxy)
                        }
                    }
                    closeButton
                }.onTapGesture {
                    isEmailFieldFocused = false
                }
            }.background(.thinMaterial)
                .tint(nil)
                .ignoresSafeArea(.all, edges: .top)
        }
        .navigationViewStyle(.stack)
        .environment(\.dismissAll, dismiss)
        .tint(.purple)
        .alertTintColor(.purple)
        .flexaAuthNavigationbar()
        .flexaPrivacyAlert(isPresented: $showingPrivacyAlert)
    }

    private var closeButton: some View {
        HStack(alignment: .top) {
            Spacer()
            FlexaRoundedButton(.close) {
                dismiss()
            }.padding()
        }.frame(maxWidth: .infinity)
    }

    private var headerView: some View {
        VStack(alignment: .center) {
            Image(uiImage: Bundle.applicationIcon ?? UIImage())
                .resizable()
                .frame(width: .appIconSize, height: .appIconSize)
                .clipShape(RoundedRectangle(cornerRadius: .appIconCornerRadius))
                .padding(.top, .appIconTopPadding)
                .shadow(
                    color: .black.opacity(.appIconShadowOpacity),
                    radius: .appIconShadowRadius,
                    x: .appIconShadowX,
                    y: .appIconShadowY
                )
        }
    }

    private var titleView: some View {
        VStack(spacing: .sectionSpacing) {
            Text(Strings.Header.title(viewModel.applicationName))
                .font(.headline.bold())
                .foregroundColor(.primary)
                .opacity(.textOpacity)
                .multilineTextAlignment(.center)
            Text(Strings.Header.subtitle)
                .font(.system(size: .headerSubtitleFontSize, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var instantPaymentImage: some View {
        Image(systemName: "bolt.shield.fill")
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(Color.purple)
            .frame(width: .bulletInstantPaymentIconSize, height: .bulletInstantPaymentIconSize)
            .padding(0)
            .padding(.leading, .bulletPrivateIconWidth - .bulletInstantPaymentIconSize)
    }

    private var privacyImage: some View {
        Image(systemName: "key.fill")
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(Color.purple)
            .rotationEffect(.degrees(90))
            .frame(width: .bulletPrivateIconWidth, height: .bulletPrivateIconHeight)
            .padding(.horizontal, 0)
            .padding(.top, -4)
    }

    private var bulletsView: some View {
        VStack(alignment: .center, spacing: .bulletSpacing) {
            bulletView(
                title: Strings.Sections.Spend.title,
                description: Strings.Sections.Spend.description,
                image: instantPaymentImage
            )
            bulletView(
                title: Strings.Sections.Privacy.title,
                description: Strings.Sections.Privacy.description,
                image: privacyImage,
                linkText: Strings.Links.About.title,
                linkAction: {
                    showingPrivacyAlert = true
                }
            )
        }
    }

    @ViewBuilder
    private var navigationLink: some View {
        NavigationLink(
            destination: VerifyEmailView(viewModel: VerifyEmailView.ViewModel(emailAddress: viewModel.emailAddress)),
            isActive: $viewModel.shouldGoVerifyEmail) {
        }
        NavigationLink(
            destination: PersonalInformationView(
                viewModel: PersonalInformationView.ViewModel(
                    emailAddress: viewModel.emailAddress
                )
            ),
            isActive: $viewModel.shouldGoPersonalInfo) {
        }
    }

    @ViewBuilder
    private var bottomView: some View {
        VStack(spacing: .bottomViewSpacing) {
            ZStack {
                TextField(Strings.Textfields.Email.placeholder, text: $viewModel.emailAddress)
                    .flexaFormTextField()
                    .clearButton(text: $viewModel.emailAddress)
                    .focused($isEmailFieldFocused)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        viewModel.verifyEmailAddress()
                    }
                if viewModel.emailAddress.isEmpty {
                    HStack {
                        Spacer()
                        Button {

                        } label: {
                            Image(systemName: "info.circle")
                                .resizable()
                                .renderingMode(.template)
                        }
                        .frame(width: .infoButtonSize, height: .infoButtonSize)
                        .foregroundStyle(Color.purple)
                        .padding()
                    }
                }
            }

            Button {
                viewModel.verifyEmailAddress()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .flexaButton()
                } else {
                    Text(Strings.Buttons.Next.title)
                        .flexaButton()
                }
            }.disabled(!viewModel.isContinueButtonEnabled)
            navigationLink
        }
    }

    private func bulletView(
        title: String,
        description: String,
        image: some View,
        linkText: String? = nil,
        linkAction: (() -> Void)? = nil) -> some View {
        HStack(alignment: .top, spacing: .bulletIconPadding) {
            image
                .padding(.top, .bulletIconTopPadding)
            VStack(alignment: .leading, spacing: .bulletContentVerticalSpacing) {
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(nil)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(description)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary.opacity(.textOpacity))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                if let linkText, let linkAction {
                    linkButton(title: linkText, perform: linkAction)
                }
            }.frame(maxWidth: .infinity)
        }.padding(.horizontal, .bulletsHorizontalPadding)
    }

    private func linkButton(title: String, perform action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.purple)
        }.padding(.top, .linkButtonTopPadding)
    }

    private func handleFocusChange(_ isFocused: Bool, scrollViewProxy: ScrollViewProxy) {
        guard isFocused else {
            bottomViewBottomPadding = .bottomViewBottomPaddingDefault
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                bottomViewBottomPadding = .bottomViewBottomPaddingOnFocus
                scrollViewProxy.scrollTo(bottomViewId, anchor: .bottom)
            }
        }
    }
}

extension CGFloat {
    static let mainSpacing: CGFloat = 30
    static let defaultPadding: CGFloat = 26
    static let sectionSpacing: CGFloat = 5
    static let headerSubtitleFontSize: CGFloat = 42
    static let linkButtonTopPadding: CGFloat = 6
    static let infoButtonSize: CGFloat = 22

    static let appIconSize: CGFloat = 84
    static let appIconTopPadding: CGFloat = 100
    static let appIconCornerRadius: CGFloat = 14
    static let appIconShadowRadius: CGFloat = 18
    static let appIconShadowX: CGFloat = 0
    static let appIconShadowY: CGFloat = 12

    static let bulletInstantPaymentIconSize: CGFloat = 36
    static let bulletPrivateIconHeight: CGFloat = 45
    static let bulletPrivateIconWidth: CGFloat = 45
    static let bulletIconPadding: CGFloat = 16
    static let bulletIconTopPadding: CGFloat = 16
    static let bulletSpacing: CGFloat = 24
    static let bulletContentVerticalSpacing: CGFloat = 4
    static let bulletsHorizontalPadding: CGFloat = 20

    static let bottomViewSpacing: CGFloat = 12
    static let bottomViewBottomPaddingOnFocus: CGFloat = 20
    static let bottomViewBottomPaddingDefault: CGFloat = 44
}

extension Double {
    static let textOpacity: Double = 0.4
    static let appIconShadowOpacity: Double = 0.20
}
