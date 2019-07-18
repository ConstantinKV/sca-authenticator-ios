//
//  WKWebViewController.swift
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2019 Salt Edge Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3 or later.
//
//  This program is distributed in the hope that it will be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//  General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <http://www.gnu.org/licenses/>.
//
//  For the additional permissions granted for Salt Edge Authenticator
//  under Section 7 of the GNU General Public License see THIRD_PARTY_NOTICES.md
//

import UIKit
import WebKit
import TinyConstraints

private struct Layout {
    static let loadingIndicatorSize: CGSize = CGSize(width: 90.0, height: 90.0)
}

protocol WKWebViewControllerDelegate: class {
    func showError(_ error: String)
}

class WKWebViewController: BaseViewController {
    weak var delegate: WKWebViewControllerDelegate?
    var messageBar: MessageBarView?
    var displayType: Presentation = .modal

    private var webView: WKWebView
    private let loadingIndicator = LoadingIndicator()

    init() {
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        super.init(nibName: nil, bundle: .authenticator_main)
    }

    override func loadView() {
        super.loadView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if displayType == .modal { setupBackButton() }
        layout()
        loadingIndicator.start()
    }

    private func setupBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: l10n(.back),
            style: .plain,
            target: self,
            action: #selector(close)
        )
    }

    @objc private func hasConnection() {
        if let messageBarView = messageBar {
            dismiss(messageBarView: messageBarView)
        }
    }

    func startLoading(with url: String) {
        guard let url = URL(string: url) else { return }

        let request = URLRequest(url: url)
        webView.load(request)
    }

    private func handleError(_ error: NSError) {
        if error.code != 102 { // error code for: Frame Load Interruped
            delegate?.showError(error.localizedDescription)
        }

        if error.code == -1009 { // error code for no Internet connection
            messageBar = present(message: error.localizedDescription, style: .error, hide: false)
        }
    }

    @objc func close() {
        dismiss(animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - WKNavigationDelegate
extension WKWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stop()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stop()
        handleError(error as NSError)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stop()
        handleError(error as NSError)
    }

    #if DEBUG
    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, credential)
    }
    #endif
}

// MARK: - Layout
extension WKWebViewController: Layoutable {
    func layout() {
        view.addSubview(loadingIndicator)
        loadingIndicator.center(in: view)
        loadingIndicator.size(Layout.loadingIndicatorSize)
    }
}
