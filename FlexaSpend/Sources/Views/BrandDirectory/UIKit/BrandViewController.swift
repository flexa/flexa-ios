//
//  BrandViewController.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 8/11/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import UIKit
import WebKit
import Factory

// MARK: BrandViewController.Link
extension BrandViewController {
    enum Link {
        static var brandDirectoryUrlString: String {
            L10n.Brand.Links.merchantList
        }

        case merchantList
        case merchantLocations(String)
        case custom(URL)

        var url: URL? {
            switch self {
            case .merchantList:
                return URL(string: Self.brandDirectoryUrlString)
            case .merchantLocations(let slug):
                return URL(string: L10n.Brand.Links.merchantLocations(Self.brandDirectoryUrlString, slug))
            case .custom(let url):
                return url
            }
        }
    }
}

class BrandViewController: UIViewController {
    @Injected(\.flexaClient) public var flexaClient: FXClient

    private var webView: WebView!
    private var activityIndicator: UIActivityIndicatorView!
    private let navBarQueryParamName = "nb"
    private let closeButtonSize: CGFloat = 30
    private let cornerRadius: CGFloat = 30
    private let closeButtonPadding: CGFloat = 13

    private var closeButton: BrandCloseButton?
    private var customNavBar: BrandNavigationBar?
    private var navBarOverlay: UIView?
    private var grabber: UIView?
    private var onDismiss: (() -> Void)?

    private var isLoading: Bool {
        activityIndicator.isAnimating
    }

    private var showCustomNavigationBar: Bool {
        guard let url = link.url else {
            return false
        }

        return NavigationBarStyle.fromRawValue(url.queryItems[navBarQueryParamName]) == .show && !isDisplayingLocations
    }

    private var showCloseButton: Bool {
        true
    }

    private var userAgent: String {
        "\(webView.userAgent) FlexaSpend/0.0.1"
    }

    private lazy var defaultURL: URL? = {
        URL(string: Link.brandDirectoryUrlString)
    }()

    private var isDisplayingLocations: Bool {
        guard let url = link.url, let defaultURL else {
            return false
        }
        return url.lastPathComponent == "locations" && url.absoluteString.starts(with: defaultURL.absoluteString)
    }

    var link: Link = .merchantList

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.view.backgroundColor = Asset.commonMainBackground.color

        setupActivityIndicator()
        setupWebView()
        setupNavigationBar()
        setupOverlay()
        setupGrabber()
        setupCloseButton()

        if let url = link.url {
            setupThemingCookie(url)
            webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if showCustomNavigationBar {
            navigationController?.isNavigationBarHidden = true
        }

        if let navigationController = navigationController {
            navigationController.sheetPresentationController?.preferredCornerRadius = cornerRadius
        }
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        onDismiss?()
    }

    @objc private func close() {
        dismiss(animated: true)
    }

    /// Scrolls down and up to activate the large title in the navigation bar when the page loads.
    /// Large titles don;t work well when the web view starts loading, the navigation bar is collapsed displaying a small title.
    private func adjustNavigationBar() {
        guard !showCustomNavigationBar, !isDisplayingLocations else {
            return
        }
        // Scroll to make UINavigationBar title small (update with accurate properties)
        let scrollPoint = CGPoint(x: 0, y: 200)
        self.webView.scrollView.setContentOffset(scrollPoint, animated: false)
        // Scroll above UINavigationController to activate the large title
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let scrollPoint = CGPoint(x: 0, y: -200)
            self.webView.scrollView.setContentOffset(scrollPoint, animated: false)
            // Scroll back
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let scrollPoint = CGPoint(x: 0, y: -94)
                self.webView.scrollView.setContentOffset(scrollPoint, animated: false)
            }
        }
    }

    private func setupNavigationBar() {
        if showCustomNavigationBar {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
            setupCustomNavigationBar()
        } else if let navigationBar = navigationController?.navigationBar {
            edgesForExtendedLayout = [.top]
            if isDisplayingLocations {
                navigationBar.prefersLargeTitles = false
                navigationItem.largeTitleDisplayMode = .never
            } else {
                navigationBar.prefersLargeTitles = true
                navigationItem.largeTitleDisplayMode = .always
            }
            navigationBar.alpha = 0
        }
    }

    private func setupWebView() {
        webView = WebView()
        webView.navigationDelegate = self
        webView.customUserAgent = userAgent
        webView.allowsBackForwardNavigationGestures = false
        webView.alpha = 0

        webView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(webView, belowSubview: activityIndicator)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

    }

    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        activityIndicator.startAnimating()
    }

    private func setupOverlay() {
        guard let navigationBar = navigationController?.navigationBar,
              let parent = navigationBar.superview, !showCustomNavigationBar else {
            return
        }

        let overlay = UIView()
        overlay.backgroundColor = Asset.commonMainBackground.color
        overlay.alpha = 1
        overlay.translatesAutoresizingMaskIntoConstraints = false
        parent.insertSubview(overlay, aboveSubview: navigationBar)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: navigationBar.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            overlay.leftAnchor.constraint(equalTo: navigationBar.leftAnchor),
            overlay.rightAnchor.constraint(equalTo: navigationBar.rightAnchor)
        ])

        navBarOverlay = overlay
    }

    private func setupGrabber() {
        guard let navigationBar = navigationController?.navigationBar, let parent = navigationBar.superview else {
            return
        }

        let grabber = UIView()
        grabber.translatesAutoresizingMaskIntoConstraints = false
        grabber.backgroundColor = .separator
        grabber.layer.cornerRadius = 2.5
        grabber.clipsToBounds = true
        parent.insertSubview(grabber, aboveSubview: navigationBar)

        NSLayoutConstraint.activate([
            grabber.widthAnchor.constraint(equalToConstant: 36),
            grabber.heightAnchor.constraint(equalToConstant: 5),
            grabber.topAnchor.constraint(equalTo: parent.topAnchor, constant: 5),
            grabber.centerXAnchor.constraint(equalTo: parent.centerXAnchor)
        ])

        self.grabber = grabber
    }

    private func setupCustomNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar,
              let parent = navigationBar.superview,
              showCustomNavigationBar else {
            return
        }

        let navBar = BrandNavigationBar(frame: .zero)
        parent.addSubview(navBar)
        NSLayoutConstraint.activate([
            navBar.leftAnchor.constraint(equalTo: parent.leftAnchor),
            navBar.rightAnchor.constraint(equalTo: parent.rightAnchor),
            navBar.topAnchor.constraint(equalTo: parent.topAnchor),
            navBar.heightAnchor.constraint(equalToConstant: navigationBar.bounds.height)
        ])

        customNavBar = navBar
    }

    private func setupCloseButton() {
        guard showCloseButton else {
            return
        }

        guard !isDisplayingLocations else {
            let button = UIBarButtonItem(
                title: L10n.Common.done,
                style: .done,
                target: self,
                action: #selector(close))

            button.tintColor = UIColor(dynamicProvider: { trait in
                trait.userInterfaceStyle == .dark ? .white : UIColor(hex: "#DC132B") ?? UIColor.systemBlue
            })
            navigationItem.setRightBarButton(button, animated: false)
            return
        }

        guard let parent = navigationController?.navigationBar.superview else {
            return
        }

        let button = BrandCloseButton(type: .system)
        button.setDisplayMode(.floating)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        parent.addSubview(button)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: closeButtonSize),
            button.heightAnchor.constraint(equalToConstant: closeButtonSize),
            button.topAnchor.constraint(equalTo: parent.topAnchor, constant: closeButtonPadding),
            button.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -closeButtonPadding)
        ])

        closeButton = button
    }

    private func setupThemingCookie(_ url: URL) {
        let theme = flexaClient.theme.webView.webViewThemeConfig?.data(using: .utf8)?.base64EncodedString() ?? ""
        let cookieProperties: [HTTPCookiePropertyKey: Any] = [
            .name: "X-Theming-Data",
            .value: theme as Any,
            .domain: url.host ?? "",
            .path: "/"
        ]

        guard let cookie = HTTPCookie(properties: cookieProperties) else {
            return
        }
        webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
    }

    private func updateTitle() {
        if showCustomNavigationBar {
            customNavBar?.title = webView.title
        } else {
            title = webView.title
        }
    }

    private func hideGrabber() {
        (grabber ?? customNavBar?.grabber)?.fadeOut()
    }

    private func showGrabber() {
        (grabber ?? customNavBar?.grabber)?.fadeIn()
    }
}

// MARK: WKNavigationDelegate
extension BrandViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url,
              navigationAction.navigationType == .linkActivated
               || (navigationAction.navigationType == .other) && !isLoading else {
            return .allow
        }

        // Any url outside /directory should open on a web browser
        var merchantUrlcomponents = defaultURL?.components
        merchantUrlcomponents?.query = nil
        if let baseUrl = merchantUrlcomponents?.url?.absoluteString, !url.absoluteString.hasPrefix(baseUrl) {
            if UIApplication.shared.canOpenURL(url) {
                await UIApplication.shared.open(url)
                return .cancel
            }

            if var components = url.components, components.scheme == "maps" {
                components.scheme = "https"
                components.host = "maps.apple.com"
                if let mapsUrl = components.url {
                    await UIApplication.shared.open(mapsUrl)
                    return .cancel
                }
            }
        }

        let webViewController = BrandViewController()
        webViewController.link = .custom(url)
        webViewController.onDismiss = {
            self.showGrabber()
        }
        hideGrabber()

        let navController = UINavigationController(rootViewController: webViewController)
        navController.presentationController?.delegate = self

        present(navController, animated: true)

        return .cancel
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.updateTitle()
            self.adjustNavigationBar()
            self.activityIndicator.stopAnimating()

            UIView.animate(
                withDuration: 0.5,
                delay: 0.2,
                animations: {
                    self.webView.addObserver(self, forKeyPath: #keyPath(WebView.title), options: .new, context: nil)
                    self.webView.alpha = 1
                    self.navBarOverlay?.alpha = 0

                    if self.showCustomNavigationBar {
                        self.closeButton?.setDisplayMode(.overHiddenNavbar)
                        self.webView.scrollView.delegate = self
                    } else {
                        self.navigationController?.navigationBar.alpha = 1
                    }
                },
                completion: { _ in
                    self.navigationController?.navigationBar.standardAppearance = UINavigationBarAppearance()
                }
            )
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.alpha = 1
        activityIndicator.stopAnimating()
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            updateTitle()
        }
    }
}

// MARK: UIScrollViewDelegate
extension BrandViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let navigationBar = customNavBar, showCustomNavigationBar else {
            return
        }

        let minOffset: CGFloat = 0
        let transition: CGFloat = 120
        let intensity = max(
            0,
            min((scrollView.contentOffset.y - navigationBar.bounds.height - minOffset) / transition, 1)
        )

        navigationBar.updateIntensity(intensity)

        if intensity < 0.3 {
            closeButton?.setDisplayMode(.overHiddenNavbar, animated: true)
        } else if intensity > 0.5 {
            closeButton?.setDisplayMode(.overNavbar, animated: true)
        }
    }
}

// MARK: UIAdaptivePresentationControllerDelegate
extension BrandViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        showGrabber()
    }
}

// MARK: URL Utils
private extension URL {
    var components: URLComponents? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)
    }

    var queryItems: [URLQueryItem] {
        components?.queryItems ?? []
    }
}

// MARK: URLQueryItem Utils
private extension Array where Iterator.Element == URLQueryItem {
    subscript(_ key: String) -> String? {
        return first(where: { $0.name == key })?.value
    }
}

// MARK: WebView
private extension BrandViewController {
    enum NavigationBarStyle: String {
        case hide = "0"
        case show = "1"

        static func fromRawValue(_ rawValue: String?) -> Self {
            guard let rawValue else {
                return .hide
            }
            return Self(rawValue: rawValue) ?? .hide
        }
    }

    class WebView: WKWebView {
        private let userAgentKeyPath = "userAgent"

        var userAgent: String {
            (value(forKey: userAgentKeyPath) as? String) ?? ""
        }

        override func value(forUndefinedKey key: String) -> Any? {
            if key == userAgentKeyPath {
                return ""
            }
            return super.value(forUndefinedKey: key)
        }
    }
}
