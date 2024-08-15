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

final class FlexaInternal: Flexa {
    /// Specifies which sections of Flexa should be displayed
    /// - parameter sections: The sections to be displayed
    static func uiSections(_ sections: [Section]) -> Builder {
        return Builder([.spend])
    }

    var sections: [Section] = []

    lazy var spendBuilder: FlexaSpend.Builder? = {
        sections.contains(.spend) ? Flexa.buildSpend() : nil
    }()

    lazy var scanBuilder: FlexaScan.Builder? = {
        sections.contains(.scan) ? Flexa.buildScan() : nil
    }()

    private var spendContent: (() -> AnyView)? {
        if let spend = spendBuilder?.build() {
            return {
                AnyView(spend.createView())
            }
        }
        return nil
    }

    private var scanContent: (() -> AnyView)? {
        if let scan = scanBuilder?.build() {
            return {
                AnyView(scan.createView())
            }
        }
        return nil
    }

    /// Opens the main screen
    ///
    /// If the user is already signed in then it will open the screens specified by the ``Flexa/sections`` method. If the user is not signed in the it will open the sign in/sign up screens.
    public func openMain() {
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
        FlexaIdentity.processUniversalLink(url: url)
    }

    /// Opens Flexa's' main screen, if the user is already signed in, or the sign in/sign up screen otherwise
    /// - parameter result: indicates if the user is authenticated (`connected`) or not
    ///
    /// If `result` is `connected` then Flexa SDK opens the main screen
    /// if `result` is `notConnected` then Flexa SDK starts the auth flow
    private func showMainOrAuth(result: ConnectResult, allowSignIn: Bool = true) {
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
