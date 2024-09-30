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
    @StateObject var viewModel: ViewModel
    @FocusState var focusedField: FocusableField?
    @State var showPicker: Bool = false
    @State var datePickerHeight: CGFloat = 0
    @State var showingPrivacyAlert: Bool = false

    let formBackgroundColor = Color(
        lightColor: UIColor(hex: "#dfdfdf"),
        darkColor: UIColor.secondaryLabel.withAlphaComponent(0.2)
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
                }
                alerts
            }
            .onAppear {
                datePickerHeight = proxy.size.width - 40
            }
            .onChange(of: proxy.size) { size in
                datePickerHeight = size.width - 40
            }
            .onTapGesture(perform: endEditing)
            .onSubmit(focusNextField)
        }
        .background(.thinMaterial)
        .tint(nil)
        .alertTintColor(.purple)
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
                        viewModel.givenName = $0
                    }))
                    .textContentType(.name)
                    .autocorrectionDisabled(true)
                    .focused($focusedField, equals: .givenName)
                    .listRowBackground(formBackgroundColor)
                    .listRowSeparatorTint(separatorColor)

                if focusedField != nil {
                    TextField(Strings.Textfields.FamilyName.placeholder, text: $viewModel.familyName)
                        .textContentType(.name)
                        .autocorrectionDisabled(true)
                        .focused($focusedField, equals: .familyName)
                        .listRowBackground(formBackgroundColor)
                        .listRowSeparatorTint(separatorColor)
                }

                    datePicker
                        .foregroundStyle(viewModel.birthDateForegroundColor)
                        .listRowBackground(formBackgroundColor)
                        .listRowSeparatorTint(separatorColor)
            }
            .onTapGesture {

            }

            Section {
                termsSection.listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
            }.onTapGesture(perform: endEditing)
        }
        .tint(.purple)
        .animation(.default, value: focusedField)
        .scrollContentBackgroundHidden(true)
        .disableScroll()
        .onTapGesture {
        }
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
                    .tint(.purple)
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
        Text(viewModel.birthDateText)
            .sheet(isPresented: $showPicker) {
                DatePicker(
                    "",
                    selection: $viewModel.dateOfBirth,
                    in: ...Date.now,
                    displayedComponents: .date
                )

                .datePickerStyle(.graphical)
                .padding()
                .pickerDetents(datePickerHeight)
            }
            .onTapGesture {
                focusedField = nil
                showPicker = true
            }
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
