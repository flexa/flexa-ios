//
//  URLRouterProtocol.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/18/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public enum FlexaLink: Equatable {
    case webView(URL?)
    case brandWebView(URL?)
    case systemBrowser(URL?)
    case paymentLink(URL)
    case account
    case accountDeletion
    case accountData
    case pinnedBrands
    case scan
    case pay
    case verify(URL?)

    public static let howToPay = FlexaLink.webView(URL(string: CoreStrings.WebLinks.howToPay))
    public static let reportIssue = FlexaLink.webView(URL(string: CoreStrings.WebLinks.reportIssue))
    public static let privacy = FlexaLink.webView(URL(string: CoreStrings.WebLinks.privacy))
    public static let merchantList = FlexaLink.brandWebView(
        URL(string: CoreStrings.WebLinks.merchantList(
            FlexaConstants.Routing.flexaNetworkDomain
        ))
    )

    var path: String? {
        switch self {
        case .account:
            return "/account"
        case .accountDeletion:
            return "/account/delete"
        case .accountData:
            return "/account/data"
        case .pinnedBrands:
            return "/pinned"
        case .scan:
            return "/scan"
        case .pay:
            return "/pay"
        case .verify:
            return "/verify"
        default:
            return nil
        }
    }

    public var url: URL? {
        switch self {
        case .systemBrowser(let url), .webView(let url), .brandWebView(let url), .verify(let url):
            return url
        case .paymentLink(let url):
            return url
        default:
            if let path {
                return URL(string: "https://\(FlexaConstants.Routing.flexaMainDomain)\(path)")
            }
            return nil
        }
    }

    public static func merchantLocations(_ slug: String) -> FlexaLink {
        .brandWebView(
            URL(string: CoreStrings.WebLinks.merchantLocations(
                CoreStrings.WebLinks.merchantList(FlexaConstants.Routing.flexaNetworkDomain),
                slug)
            )
        )
    }
}

public protocol URLRouterProtocol {
    func getLink(from: URL?) -> FlexaLink?
}
