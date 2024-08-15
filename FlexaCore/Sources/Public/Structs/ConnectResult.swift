//
//  ConnectResult.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 11/25/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation

/// Contains the login/connect information about for the current user, including the state and the idToken
public enum ConnectResult {
    /// User is connected to Flexa Network
    /// - parameter : the   `idToken` to be used on future requests
    case connected
    /// User is not connected to Flexa Network
    /// - parameter : an error in case something went wrong, or just `nil` if the user was not connected
    case notConnected(Error?)
}
