//
//  URLRouter.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/18/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

enum FlexaLink {
    case webView(URL?)
    case systemBrowser(URL?)
    case account

    static let howToPay = FlexaLink.webView(URL(string: L10n.WebLinks.howToPay))
    static let reportIssue = FlexaLink.webView(URL(string: L10n.WebLinks.reportIssue))

    var path: String? {
        switch self {
        case .account:
            return "/account"
        default:
            return nil
        }
    }

    var url: URL? {
        switch self {
        case .systemBrowser(let url), .webView(let url):
            return url
        default:
            return nil
        }
    }
}

protocol URLRouterProtocol {
    func getLink(from: URL?) -> FlexaLink?
}

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

        guard url.components?.path == FlexaLink.account.path else {
            return .webView(replaceDomain(for: url))
        }

        return .account
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
}
