//
//  FlexaWebView.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/17/24.
//

import SwiftUI
import FlexaUICore

public struct FlexaWebView: View {
    let url: URL?
    let adjustContent: Bool
    @State var isLoading = true
    @State var error: Error?
    @Environment(\.dismiss) private var dismiss

    public init(url: URL?, adjustContent: Bool = false) {
        self.url = url
        self.adjustContent = adjustContent
    }

    public var body: some View {
        if Flexa.supportsGlass {
            NavigationView {
                content
                    .ignoresSafeArea()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            FlexaRoundedButton(.close) {
                                dismiss()
                            }
                        }
                    }
            }
        } else {
            content
        }
    }

    private var content: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemBackground)
            ZStack(alignment: .center) {
                if let url, error == nil {
                    WebViewWrapper(url: url, adjustContent: adjustContent, isLoading: $isLoading, error: $error)
                }
                if isLoading {
                    ProgressView().tint(.flexaTintColor)
                } else if error != nil {
                    VStack(spacing: 20) {
                        Text(CoreStrings.Webview.Errors.Load.title)
                            .font(.title)
                        Button {
                            self.error = nil
                        } label: {
                            Label {
                                Text(CoreStrings.Webview.Buttons.Retry.title)
                            } icon: {
                                Image(systemName: "arrow.clockwise")
                            }.foregroundColor(.flexaTintColor)
                        }
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)

            if !Flexa.supportsGlass {
                closeButton
            }
        }
    }

    private var closeButton: some View {
        HStack(alignment: .top) {
            Spacer()
            FlexaRoundedButton(.close) {
                dismiss()
            }.padding()
        }.frame(maxWidth: .infinity)
    }
}
