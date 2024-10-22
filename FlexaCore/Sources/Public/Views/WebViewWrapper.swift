//
//  WebViewWrapper.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 17/10/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import WebKit
import SwiftUI

struct WebViewWrapper: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var error: Error?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WebView {
        let webView = WebView()
        let request = URLRequest(url: url)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = "\(webView.userAgent) FlexaSpend/ \(Flexa.version)"
        webView.load(request)
        return webView
    }

    func updateUIView(_ webView: WebView, context: Context) {
    }
}

extension WebViewWrapper {
    class WebView: WKWebView {
        private let userAgentKeyPath = "userAgent"

        var userAgent: String {
            (value(forKey: userAgentKeyPath) as? String) ?? ""
        }

        override func value(forUndefinedKey key: String) -> Any? {
            if key == userAgentKeyPath {
                return ""
            }
            return super.value(forUndefinedKey: key)
        }
    }
}

extension WebViewWrapper {
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewWrapper

        init(_ parent: WebViewWrapper) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            FlexaLogger.error(error)
            parent.isLoading = false
            parent.error = error
        }
    }
}
