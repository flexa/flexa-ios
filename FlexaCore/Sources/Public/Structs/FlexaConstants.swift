//
//  FlexaConstants.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 9/27/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation

public enum FlexaConstants {
    public static let usdAssetId = "iso4217/USD"

    public enum Routing {
        public static let flexaMainDomain = "flexa.co"
        public static let flexaLinkDomain = "flexa.link"
        public static let flexaNetworkDomain = "flexa.network"
        public static let flexaDomains = [flexaMainDomain, flexaLinkDomain, flexaNetworkDomain]
        // swiftlint:disable:next line_length
        public static let flexaPaymentLinkRegexPattern = #"^(?:https:\/\/)?pay(?:\.[a-zA-Z0-9-]+)*\.(flexa\.co|flexa\.link)(?:\/[^\s?#]*)?(?:\?[^\s#]*)?(?:#[^\s]*)?$"#
    }
}
