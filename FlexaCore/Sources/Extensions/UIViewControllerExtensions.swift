//
//  UIViewControllerExtensions.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 01/23/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import UIKit
import SwiftUI

public extension UIViewController {
    class var topMostViewController: UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0.activationState == .foregroundActive ? $0 as? UIWindowScene : nil })
            .first else {
                return nil
            }

        guard let rootViewController = scene
            .windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController else {
            return nil
        }
        return rootViewController.topPresentedViewController()
    }

    class func showViewOnTop<T: View>(_ view: T, showGrabber: Bool = false) {
        let uiHostingController = UIHostingController(rootView: view)
        uiHostingController.view.backgroundColor = .clear
        showOnTop(uiHostingController, showGrabber: showGrabber)
    }

    class func showOnTop(_ viewController: UIViewController, showGrabber: Bool = false) {
        viewController.sheetPresentationController?.preferredCornerRadius = 30
        viewController.sheetPresentationController?.prefersGrabberVisible = showGrabber
        topMostViewController?
            .topPresentedViewController()
            .present(viewController, animated: true)
    }

    func topPresentedViewController() -> UIViewController {
      return presentedViewController?.topPresentedViewController() ?? self
    }

    func findNavigationController() -> UINavigationController? {
        if let navigationController = self as? UINavigationController {
            return navigationController
        }
        return self.children.compactMap { $0.findNavigationController() }.first
    }

    func showAlert(error: ReasonableError) {
        let alertController = UIAlertController(
            title: error.title,
            message: error.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
