//
//  View+FlexaUniversalLink.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 12/19/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI
import Factory

public extension View {
    func flexaHandleUniversalLink(_ handler: ((URL?) -> Bool)? = nil) -> some View {
        modifier(FlexaUniversalLinkHandlerModifier(handler))
    }
}

public struct FlexaUniversalLinkHandlerModifier: ViewModifier {
    @EnvironmentObject var linkData: UniversalLinkData
    @Environment(\.openURL) private var openURL
    @Injected(\.urlRouter) var urlRouter
    @State var isShowingWebView: Bool = false
    @State var isShowingFlexaAccountSheet = false
    @State var isShowingBrandDirectory = false
    @State var url: URL?

    private var handler: ((URL?) -> Bool)?

    init(_ handler: ((URL?) -> Bool)? = nil) {
        self.handler = handler
    }

    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isShowingWebView) {
                FlexaWebView(url: url).ignoresSafeArea()
            }
            .sheet(isPresented: $isShowingFlexaAccountSheet) {
                AccountView()
            }
            .sheet(isPresented: $isShowingBrandDirectory) {
                BrandView().ignoresSafeArea()
            }
            .environment(\.openURL, OpenURLAction { url in
                handleUrl(url) ? .handled : .systemAction(url)
            })
            .onChange(of: linkData.url) { url in
                handleUrl(url)
            }
    }

    @discardableResult
    private func handleUrl(_ url: URL?) -> Bool {
        guard let url else {
            return true
        }

        if let handler, handler(url) {
            return true
        }

        if let link = url.flexaLink {
            switch link {
            case .webView(let linkUrl):
                self.url = linkUrl
                isShowingWebView = true
            case .brandWebView(let linkUrl):
                self.url = linkUrl
                isShowingBrandDirectory = true
            case .systemBrowser(let linkUrl):
                openURL(linkUrl ?? url)
            case .account:
                isShowingFlexaAccountSheet = true
            case .accountData, .accountDeletion:
                isShowingFlexaAccountSheet = true
                linkData.url = url
            case .verify(let url):
                linkData.url = url
            case .paymentLink(let url):
                linkData.url = url
            case .scan, .pay, .pinnedBrands:
                linkData.url = url
            }
            return true
        }
        return false
    }
}
