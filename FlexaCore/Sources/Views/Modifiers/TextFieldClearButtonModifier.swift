//
//  TextFieldClearButtonModifier.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/3/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI

extension View {
    func clearButton(text: Binding<String>) -> some View {
        modifier(ClearButtonModifier(text: text))
    }
}

struct ClearButtonModifier: ViewModifier {
    @Binding var text: String

    func body(content: Content) -> some View {
        content
            .overlay {
                if !text.isEmpty {
                    HStack {
                        Spacer()
                        Button {
                            text = ""
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 22, height: 22)
                                    .foregroundStyle(Color(.systemGray4).opacity(0.78))
                                Image(systemName: "multiply")
                                    .imageScale(.small)
                                    .foregroundStyle(Color(.systemGray))
                            }
                        }
                        .padding()
                    }
                }
            }
    }
}
