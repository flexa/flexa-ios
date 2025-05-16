//
//  URLRouter.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/18/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

struct URLRouter: URLRouterProtocol {
    var appLinkDomain = "\(Bundle.applicationDisplayName).\(FlexaConstants.Routing.flexaLinkDomain)"
    let pathsToReplaceHost = ["/guides", "/explore"]

    func getLink(from url: URL?) -> FlexaLink? {
        guard let url else {
            return nil
        }

        guard isFlexaUrl(url) else {
            return .systemBrowser(url)
        }

        return lookByExactPath(url) ?? lookByPrefixPath(url) ?? lookForBrandDirectory(url) ?? .webView(replaceDomain(for: url))
    }

    func isFlexaUrl(_ url: URL) -> Bool {
        FlexaConstants.Routing.flexaDomains.contains(url.sld)
    }

    func replaceDomain(for url: URL) -> URL {
        guard var components = url.components, shouldReplaceDomain(for: url) else {
            return url
        }
        components.host = FlexaConstants.Routing.flexaMainDomain
        return components.url ?? url
    }

    func shouldReplaceDomain(for url: URL) -> Bool {
        guard isFlexaUrl(url), let path = url.components?.path else {
            return false
        }

        return pathsToReplaceHost.contains(where: {
            path == $0 || path.hasPrefix("\($0)/")
        })
    }

    func lookByExactPath(_ url: URL) -> FlexaLink? {
        if url.components?.path == FlexaLink.account.path {
            return .account
        }

        if url.components?.path == FlexaLink.accountData.path {
            return .accountData
        }

        if url.components?.path == FlexaLink.accountDeletion.path {
            return .accountDeletion
        }

        if url.components?.path == FlexaLink.pinnedBrands.path {
            return .pinnedBrands
        }

        if url.components?.path == FlexaLink.scan.path {
            return .scan
        }

        if url.components?.path == FlexaLink.pay.path {
            return .pay
        }
        return nil
    }

    func lookByPrefixPath(_ url: URL) -> FlexaLink? {
        if let path = url.components?.path, let payPath = FlexaLink.pay.path, path.hasPrefix("\(payPath)/") {
            return .paymentLink(url)
        }

        if let path = url.components?.path, let verifyPath = FlexaLink.verify(url).path, path.hasPrefix(verifyPath) {
            return .verify(url)
        }
        return nil
    }

    func lookForBrandDirectory(_ url: URL) -> FlexaLink? {
        for domain in FlexaConstants.Routing.flexaDomains {
            if url.absoluteString.hasPrefix(CoreStrings.WebLinks.merchantList(domain)) {
                return .brandWebView(url)
            }
        }
        return nil
    }
}
