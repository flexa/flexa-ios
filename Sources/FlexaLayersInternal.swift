//
//  FlexaInternal.swift
//  Flexa SDK
//
//  Created by Rodrigo Ordeix on 4/17/23.
//  Copyright © 2022 Flexa. All rights reserved.
//

import UIKit
import SwiftUI
import FlexaCore
import Factory

final class FlexaInternal: Flexa {
    @Injected(\.appStateManager) private var appStateManager
    /// Specifies which sections of Flexa should be displayed
    /// - parameter sections: The sections to be displayed
    static func uiSections(_ sections: [Section]) -> Builder {
        allowedSections = sections
        return Builder(sections)
    }

    private static var allowedSections: [Section] = []

    var sections: [Section] = []

    lazy var spendBuilder: FlexaSpend.Builder? = {
        sections.contains(.spend) ? Flexa.buildSpend() : nil
    }()

    lazy var scanBuilder: FlexaScan.Builder? = {
        sections.contains(.scan) ? Flexa.buildScan() : nil
    }()

    lazy var spend: FlexaSpend? = {
        spendBuilder?.build()
    }()

    lazy var scan: FlexaScan? = {
        scanBuilder?.build()
    }()

    private static var sectionModules: [Section: AnyClass] {
        let allModules: [Section: AnyClass] = [
            .spend: FlexaSpend.self,
            .scan: FlexaScan.self,
            .load: FlexaLoad.self
        ]
        return allModules.filter { allowedSections.contains($0.key) }
    }

    private static var linkHandlers: [UniversalLinkHandlerProtocol.Type] {
        ([FlexaIdentity.self] + Array(sectionModules.values))
            .compactMap { $0 as? UniversalLinkHandlerProtocol.Type }
    }

    private var spendContent: (() -> AnyView)? {
        guard let spend else {
            return nil
        }
        return {
            AnyView(spend.createView())
        }
    }

    private var scanContent: (() -> AnyView)? {
        guard let scan else {
            return nil
        }
        return {
            AnyView(scan.createView())
        }
    }

    /// Opens the main screen
    ///
    /// If the user is already signed in then it will open the screens specified by the ``Flexa/sections`` method. If the user is not signed in the it will open the sign in/sign up screens.
    public func openMain() {
        appStateManager.closeCommerceSessionOnDismissal = true
        guard Flexa.canSpend else {
            FlexaLogger.error("Flexa is running on a restricted region and spends are disabled. Please check Flexa.canSpend")
            FlexaIdentity.showRestrictedRegionView()
            return
        }
        Flexa
            .buildIdentity()
            .build()
            .collect { result in
                self.showMainOrAuth(result: result)
            }
    }

    /// Handles universal links received by the parent application. Currently allows you to use universal links to speed up the sign in/sign up process.
    /// - parameter url: The url to be processed
    /// - returns: true if the SDK recongizes and is able to handle the url, and false otherwise
    static func handleUniversalLink(url: URL) -> Bool {
        for handler in linkHandlers {
            if handler.processUniversalLink(url: url) {
                return true
            }
        }
        return false
    }

    /// Opens Flexa's' main screen, if the user is already signed in, or the sign in/sign up screen otherwise
    /// - parameter result: indicates if the user is authenticated (`connected`) or not
    ///
    /// If `result` is `connected` then Flexa SDK opens the main screen
    /// if `result` is `notConnected` then Flexa SDK starts the auth flow
    private func showMainOrAuth(result: ConnectResult, allowSignIn: Bool = true) {
        guard Flexa.canSpend else {
            FlexaLogger.error("Flexa is running on a restricted region and spends are disabled. Please check Flexa.canSpend")
            FlexaIdentity.showRestrictedRegionView()
            return
        }
        DispatchQueue.main.async { [self] in
            switch result {
            case .connected:
                UIViewController.showViewOnTop(
                    FlexaView(scanContent: scanContent, payContent: spendContent)
                )
            case .notConnected:
                if allowSignIn {
                    Flexa.buildIdentity()
                        .onResult { result in
                            self.showMainOrAuth(result: result, allowSignIn: false)
                        }
                        .build()
                        .open()
                }
            }
        }
    }
}
