//
//  FlexaScan.swift
//  FlexaScan
//
//  Created by Rodrigo Ordeix on 10/5/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

@_exported import FlexaCore
import SwiftUI
import Factory
import FlexaUICore

public final class FlexaScan {
    @Injected(\.scanConfig) private var config
    @Injected(\.appStateManager) private var appStateManager

    public typealias BrowseHandoff = (FlexaScan.Code) -> Void

    private var onTransactionRequest: Flexa.TransactionRequestCallback?
    private var onSendHandoff: Flexa.SendHandoff?
    private var onBrowseHandoff: BrowseHandoff?
    private var allowToDisablePayWithFlexa: Bool = false

    private init() {
    }

    public func open() {
        appStateManager.resetState()
        UIViewController.showViewOnTop(createStandaloneView())
    }

    public func createView() -> some View {
        return ScannerView(
            onTransactionRequest: onTransactionRequest,
            onSend: onSendHandoff,
            allowToDisablePayWithFlexa: allowToDisablePayWithFlexa
        )
    }
}

public extension FlexaScan {
    final class Builder {
        private var scanner = FlexaScan()

        fileprivate init() {
        }

        @discardableResult
        public func config(_ config: FlexaScan.Config) -> Self {
            self.scanner.config.allowedSymbols = config.allowedSymbols
            self.scanner.config.minConfidence = config.minConfidence
            return self
        }

        /// Specifies the callback to be called by Flexa when a transaction should be signed and sent by the parent application
        /// - parameter callback: Will be invoked by Flexa when a transaction is ready to be signed and sent. The callback will receive a `succes` with a `Transaction` object with all the information the parent application will need or a `failure` with an `Error`
        /// - returns self instance in order to chain other methods
        @discardableResult
        public func onTransactionRequest(_ callback: @escaping Flexa.TransactionRequestCallback) -> Self {
            self.scanner.onTransactionRequest = callback
            return self
        }

        @discardableResult
        public func onSendHandoff(_ callback: @escaping Flexa.SendHandoff) -> Self {
            self.scanner.onSendHandoff = callback
            return self
        }

        @discardableResult
        public func onBrowseHandoff(_ callback: @escaping BrowseHandoff) -> Self {
            self.scanner.onBrowseHandoff = callback
            return self
        }

        @discardableResult
        public func allowToDisablePayWithFlexa(_ allow: Bool) -> Builder {
            self.scanner.allowToDisablePayWithFlexa = allow
            return self
        }

        @discardableResult
        public func build() -> FlexaScan {
            let scanner = self.scanner
            self.scanner = FlexaScan()
            return scanner
        }

        public func open() {
            build().open()
        }

        public func createView() -> some View {
            build().createView()
        }
    }
}

public extension Flexa {
    static func buildScan() -> FlexaScan.Builder {
        FlexaScan.Builder()
    }
}

private extension FlexaScan {
    struct StandaloneScannerView<Content: View>: View {
        @Environment(\.theme) private var theme
        @Environment(\.colorScheme) private var colorScheme

        @StateObject var linkData: UniversalLinkData = Container.shared.universalLinkData()
        @StateObject var flexaState = Container.shared.flexaState()
        var content: () -> Content

        var body: some View {
            content()
                .environmentObject(flexaState)
                .flexaHandleUniversalLink()
                .environmentObject(linkData)
                .theme(theme)
                .environment(\.colorScheme, theme.interfaceStyle.colorSheme ?? colorScheme)
        }

        init(@ViewBuilder content: @escaping () -> Content) {
            self.content = content
        }
    }

    @ViewBuilder
    func createStandaloneView() -> some View {
        StandaloneScannerView(content: createView)
    }
}
