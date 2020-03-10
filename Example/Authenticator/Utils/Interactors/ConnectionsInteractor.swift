//
//  ConnectionsInteractor.swift
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

import Foundation
import SEAuthenticator

struct ConnectionsInteractor {
    static func createNewConnection(
        from url: URL,
        with connectQuery: String?,
        success: @escaping (Connection, AccessToken) -> (),
        redirect: @escaping (Connection, String) -> (),
        failure: @escaping (String) -> ()
    ) {
        fetchProvider(
            from: url,
            success: { response in
                let connection = Connection()
                connection.code = response.code

                if ConnectionsCollector.connectionNames.contains(response.name) {
                    connection.name = "\(response.name) (\(ConnectionsCollector.connectionNames.count + 1))"
                } else {
                    connection.name = response.name
                }

                connection.supportEmail = response.supportEmail
                connection.logoUrlString = response.logoUrl?.absoluteString ?? ""
                connection.baseUrlString = response.connectUrl.absoluteString

                requestCreateConnection(
                    connection: connection,
                    connectQuery: connectQuery,
                    success: success,
                    redirect: redirect,
                    failure: failure
                )
            },
            failure: failure
        )
    }

    static func fetchProvider(from url: URL,
                              success: @escaping (SEProviderResponse) -> (),
                              failure: @escaping (String) -> ()) {
        SEProviderManager.fetchProviderData(
            url: url,
            onSuccess: success,
            onFailure: failure
        )
    }

    static func requestCreateConnection(
        connection: Connection,
        connectQuery: String?,
        success: @escaping (Connection, AccessToken) -> (),
        redirect: @escaping (Connection, String) -> (),
        failure: @escaping (String) -> ()
    ) {
        guard let connectionData = SEConnectionData(code: connection.code, tag: connection.guid),
            let connectUrl = connection.baseUrl?.appendingPathComponent(SENetPaths.connections.path) else { return }

        SEConnectionManager.createConnection(
            by: connectUrl,
            data: connectionData,
            pushToken: UserDefaultsHelper.pushToken,
            connectQuery: connectQuery,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            onSuccess: { response in
                connection.id = response.id
                if let accessToken = response.accessToken {
                    success(connection, accessToken)
                } else if let connectUrl = response.connectUrl {
                    redirect(connection, connectUrl)
                } else {
                    failure(l10n(.somethingWentWrong))
                }
            },
            onFailure: failure
        )
    }

    static func revoke(_ connection: Connection, expiresAt: Int, success: (() -> ())? = nil) {
        guard let baseUrl = connection.baseUrl else { return }

        let data = SERevokeConnectionData(id: connection.id, guid: connection.guid, token: connection.accessToken)

        SEConnectionManager.revokeConnection(
            by: baseUrl,
            data: data,
            expiresAt: expiresAt,
            appLanguage: UserDefaultsHelper.applicationLanguage,
            onSuccess: { _ in
                success?()
            },
            onFailure: { error in
                print(error)
            }
        )
    }
}
