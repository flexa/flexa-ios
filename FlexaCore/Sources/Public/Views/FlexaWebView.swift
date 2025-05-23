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
    @State var isLoading = true
    @State var error: Error?
    @Environment(\.dismiss) private var dismiss

    public init(url: URL?) {
        self.url = url
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemBackground)
            ZStack(alignment: .center) {
                if let url, error == nil {
                    WebViewWrapper(url: url, isLoading: $isLoading, error: $error)
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
            closeButton
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
