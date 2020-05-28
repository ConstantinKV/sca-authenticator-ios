//
//  ConnectViewCoordinator.swift
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
import SEAuthenticator

final class ConnectViewCoordinator: Coordinator {
    private let rootViewController: UIViewController

    private lazy var webViewController = ConnectorWebViewController()
    private var connectViewController = ConnectViewController()
    private var connectHandler: ConnectHandler?

    private var connection: Connection?
    private let connectionType: ConnectionType

    init(rootViewController: UIViewController, connectionType: ConnectionType) {
        self.rootViewController = rootViewController
        self.connectionType = connectionType
        self.connectHandler = ConnectHandler(connectionType: connectionType)
    }

    func start() {
        connectHandler?.delegate = self
        connectHandler?.startHandling()

        rootViewController.present(
            UINavigationController(rootViewController: connectViewController),
            animated: true
        )
    }

    func stop() {}

    private func checkInternetConnection() {
        guard ReachabilityManager.shared.isReachable else {
            self.connectViewController.showInfoAlert(
                withTitle: l10n(.noInternetConnection),
                message: l10n(.pleaseTryAgain),
                actionTitle: l10n(.ok),
                completion: {
                    self.connectViewController.dismiss(animated: true)
                }
            )
            return
        }
    }
}

// MARK: - ConnectEventsDelegate
extension ConnectViewCoordinator: ConnectEventsDelegate {
    func showWebViewController() {
        webViewController.delegate = self
        connectViewController.add(webViewController)
        switch connectionType {
        case .reconnect: connectViewController.title = l10n(.reconnect)
        default: connectViewController.title = l10n(.newConnection)
        }
    }

    func finishConnectWithSuccess(message: String) {
        webViewController.remove()
        connectViewController.navigationItem.leftBarButtonItem = nil
        connectViewController.showCompleteView(with: .success, title: message)
    }

    func startWebViewLoading(with connectUrlString: String) {
        webViewController.startLoading(with: connectUrlString)
    }

    func dismiss() {
        connectViewController.dismiss(animated: true)
    }

    func dismissConnectWithError(error: String) {
        connectViewController.dismiss(
            animated: true,
            completion: {
                self.rootViewController.present(message: error, style: .error)
            }
        )
    }
}

// MARK: - ConnectorWebViewControllerDelegate
extension ConnectViewCoordinator: ConnectorWebViewControllerDelegate {
    func connectorConfirmed(url: URL, accessToken: AccessToken) {
        connectHandler?.saveConnectionAndFinish(with: accessToken)
    }

    func showError(_ error: String) {
        connectViewController.showCompleteView(with: .fail, title: error, description: l10n(.tryAgain))
    }
}
