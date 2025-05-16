//
//  PersonalInformationView.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 7/1/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI
import DeviceKit
import SwiftUIIntrospect

struct PersonalInformationView: View {
    typealias Strings = CoreStrings.Auth.PersonalInfo

    enum FocusableField: Hashable {
        case givenName, familyName
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ViewModel
    @FocusState var focusedField: FocusableField?
    @State var showPicker: Bool = false
    @State var showingPrivacyAlert: Bool = false

    let datePickerHeight = UIScreen.main.bounds.width - 40
    let formBackgroundColor = Color(
        lightColor: UIColor(hex: "#dfdfdf"),
        darkColor: UIColor(hex: "#3A3A3A")
    )

    let separatorColor = Color(
        lightColor: UIColor.separator,
        darkColor: UIColor.secondarySystemBackground
    )

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                ScrollView(.vertical) {
                    VStack(alignment: .center, spacing: 12) {
                        header.padding(.horizontal, 20)
                        form.frame(minHeight: 280)
                            .offset(y: -24)
                        Spacer()
                        footer

                    }.frame(minHeight: proxy.size.height)
                        .padding(.horizontal, 24)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: endEditing)
                }
                alerts
            }
            .onSubmit(focusNextField)
        }
        .background(.thinMaterial)
        .tint(nil)
        .alertTintColor(.flexaTintColor)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    goBack()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.backward")
                            .font(.body.bold())
                        Text(CoreStrings.Global.back)
                    }
                }.offset(x: -8)
            }
        }
        .sheet(isPresented: $showPicker) {
            DatePicker(
                "",
                selection: $viewModel.dateOfBirth,
                in: ...Date.now,
                displayedComponents: .date
            )
            .preferredColorScheme(colorScheme)
            .datePickerStyle(.graphical)
            .padding()
            .pickerDetents(datePickerHeight)
        }
        NavigationLink(
            destination: VerifyEmailView(
                viewModel: VerifyEmailView.ViewModel(
                    emailAddress: viewModel.emailAddress,
                    registering: true
                )
            ),
            isActive: $viewModel.shouldGoVerifyEmail) {
        }
    }

    @ViewBuilder
    private var header: some View {
        Image(systemName: "person.text.rectangle.fill")
            .font(.system(size: 48, weight: .bold))
            .foregroundStyle(Color.flexaTintColor)
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

    @ViewBuilder
    private var form: some View {
        Form {
            Section {
                TextField(givenNamePlaceholder, text: .init(
                    get: {
                        focusedField == nil ? viewModel.fullName : viewModel.givenName
                    }, set: {
                        guard focusedField == .givenName else {
                            return
                        }
                        viewModel.givenName = $0.trims()
                    }))
                .textContentType(.givenName)
                .autocorrectionDisabled(true)
                .focused($focusedField, equals: .givenName)
                .submitLabel(.next)
                .listRowBackground(formBackgroundColor)
                .listRowSeparatorTint(separatorColor)

                if focusedField != nil {
                    TextField(Strings.Textfields.FamilyName.placeholder, text: $viewModel.familyName)
                        .textContentType(.familyName)
                        .autocorrectionDisabled(true)
                        .focused($focusedField, equals: .familyName)
                        .submitLabel(.next)
                        .listRowBackground(formBackgroundColor)
                        .listRowSeparatorTint(separatorColor)
                }

                datePicker
                    .foregroundStyle(viewModel.birthDateForegroundColor)
                    .listRowBackground(formBackgroundColor)
                    .listRowSeparatorTint(separatorColor)
            }

            Section {
                termsSection.listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .onTapGesture(perform: endEditing)
            }
        }
        .tint(.flexaTintColor)
        .animation(.default, value: focusedField)
        .scrollContentBackgroundHidden(true)
        .disableScroll()
        .simultaneousGesture(TapGesture().onEnded {
        })
    }

    private var termsSection: some View {
        Text(.init(Strings.Sections.termsOfService(viewModel.applicationName)))
            .foregroundColor(.primary.opacity(0.4))
            .lineLimit(nil)
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var footer: some View {
        VStack(spacing: 28) {
            Spacer()
            Button {
                showingPrivacyAlert = true
            } label: {
                Text(Strings.Buttons.About.title)
                    .tint(.flexaTintColor)
                    .font(.body.weight(.semibold))
            }
            Button {
                viewModel.createAccount()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .flexaButton()
                } else {
                    Text(Strings.Buttons.Next.title)
                        .flexaButton()
                }
            }.disabled(!viewModel.isValid)
        }.padding(.bottom, 70)
    }

    @ViewBuilder
    private var datePicker: some View {
        ZStack(alignment: .leading) {
            formBackgroundColor
            Text(viewModel.birthDateText)
        }
        .highPriorityGesture(TapGesture().onEnded {
            focusedField = nil
            showPicker = true
        })
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var alerts: some View {
        blankView().flexaPrivacyAlert(isPresented: $showingPrivacyAlert)
        blankView().onError(error: $viewModel.error)
    }

    private var givenNamePlaceholder: String {
        if focusedField != nil {
            return Strings.Textfields.GivenName.placeholder
        }
        return Strings.Textfields.FullName.placeholder
    }

    private func focusNextField() {
        switch focusedField {
        case .givenName:
            focusedField = .familyName
        case .familyName:
            focusedField = nil
            showPicker = true
        case nil:
            break
        }
    }

    private func endEditing() {
        withAnimation {
            focusedField = nil
        }
    }

    private func goBack() {
        let delay = focusedField != nil ? 0.2 : 0
        endEditing()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.dismiss()
        }
    }
}

private extension View {

    @ViewBuilder
    func pickerDetents(_ height: CGFloat) -> some View {
        if #available(iOS 16.0, *) {
            self.presentationDetents([.height(height)])
        } else {
            self.introspect(.sheet, on: .iOS(.v15)) {
                ($0 as? UISheetPresentationController)?.detents = [.medium()]
            }
        }
    }
}
