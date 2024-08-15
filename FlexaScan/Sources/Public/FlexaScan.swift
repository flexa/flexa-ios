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

public final class FlexaScan {
    @Injected(\.scanConfig) private var config

    public typealias BrowseHandoff = (FlexaScan.Code) -> Void

    private var onTransactionRequest: Flexa.TransactionRequestCallback?
    private var onSendHandoff: Flexa.SendHandoff?
    private var onBrowseHandoff: BrowseHandoff?

    private init() {
    }

    public func open() {
        let view = createView()
        UIViewController.showViewOnTop(view)
    }

    public func createView() -> some View {
        return ScannerView(onTransactionRequest: onTransactionRequest,
                           onSend: onSendHandoff)
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
