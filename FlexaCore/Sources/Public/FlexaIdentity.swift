//
//  FlexaIdentity.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 10/5/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Factory
import Foundation
import UIKit
import SwiftUI

/// The entry point of the FlexaIdentity module.
public final class FlexaIdentity {
    private static var linkData: UniversalLinkData = UniversalLinkData()
    private static let universalLinkDomain = FlexaConstants.Routing.flexaLinkDomain
    private var onResultCallback: ((ConnectResult) -> Void)?
    private var delayCallbacks = true
    private let authStore: AuthStoreProtocol?

    private init() {
        authStore = Container.shared.authStore()
        authStore?.purgeIfNeeded()
    }

    /// Opens the Auth flow
    ///
    /// If the user is already signed in then it will open the payment screen.
    /// If the user is not signed in the it will open the sign in/sign up screens.
    public func open() {
        UIViewController.showViewOnTop(
            createView()
        )
    }

    public func createView() -> some View {
        AuthMainView()
            .environmentObject(FlexaIdentity.linkData)
            .onLoginResult(onResultCallback)
    }

    public static func showRestrictedRegionView() {
        UIViewController.showViewOnTop(RestrictedRegionView(), showGrabber: true)
    }

    /// Queries the login state into Flexa network.
    /// - parameter completion: The block that will handle the result of the query
    ///
    /// Auth module checks and refresh the auth tokens. In case there are not tokens or tokens cannot be refreshed the result will be always `notConnected`
    public func collect(_ completion: @escaping (ConnectResult) -> Void) {
        Task {
            var status = ConnectResult.notConnected(nil)
            do {
                switch try await authStore?.refreshTokenIfNeeded() {
                case .loggedIn:
                    status = .connected
                default:
                    status = .notConnected(nil)
                }
            } catch let error {
                status = .notConnected(error)
            }
            performOnMainQueue {
                completion(status)
            }
        }
    }

    /// Closes/dismisses any screen realted to the auth flow
    public func close() {
    }

    /// Clears all the auth information.
    public static func disconnect() {
        Container.shared.authStore().signOut()
        Container.shared.keychainHelper().purgeAll()
        Container.shared.userDefaults().purgeAll()
        Container.shared.oneTimeKeysRepository().purgeAll()
        Container.shared.accountRepository.reset()
        Container.shared.appNotificationsRepository.reset()
        Container.shared.assetsRepository().backgroundRefresh()
    }

    /// Handles universal links received by the parent application
    /// - parameter url: The url to be processed
    /// - returns: true if SpendAuth recongizes and is able to handle the url, and false otherwise
    public static func processUniversalLink(url: URL) -> Bool {
        guard url.sld == universalLinkDomain else {
            return false
        }
        linkData.url = url
        return true
    }

    /// Retrieves the information related to the current user
    /// - parameter completion: The block that will handle the result of the query
    public static func getUserData(_ completion: @escaping (UserData?) -> Void) {
        completion(nil)
    }
}

public extension FlexaIdentity {
    final class Builder {
        private var identity = FlexaIdentity()

        fileprivate init() {
        }

        /// Sets the block/callback to be called with the result of the connection to Flexa Network
        /// - parameter callback: The block that will handle the result of the query
        /// - returns self instance in order to chain other methods
        @discardableResult
        public func onResult(_ callback: @escaping (ConnectResult) -> Void) -> Builder {
            identity.onResultCallback = callback
            return self
        }

        /// Set  a flag indicating when the callbacks should be called after the dismissal of all FlexaIdentity's screens
        ///
        /// The default configuration value is true
        /// - parameter delay: true if the callbacks should be invoked after all FlexaIdentity's screens were dimissed, false to invoke the callbacks before the dismissal.
        @discardableResult
        public func delayCallbacks(_ delay: Bool) -> Builder {
            identity.delayCallbacks = delay
            return self
        }

        /// Builds a new instance of FlexaIdentity based on the configuration specified by the other builder methods (`onResult`)
        public func build() -> FlexaIdentity {
            let identity = self.identity
            self.identity = FlexaIdentity()
            return identity
        }
    }
}

public extension Flexa {
    /// Creates a builder for FlexaIdentity
    /// - returns a new instance FlexaIdentity.Builder that should be used to configure and build a new `FlexaIdentity` object
    static func buildIdentity() -> FlexaIdentity.Builder {
        FlexaIdentity.Builder()
    }
}

private extension FlexaIdentity {
    func performOnMainQueue(_ block: @escaping () -> Void) {
        Task {
            await MainActor.run {
                block()
            }
        }
    }
}
