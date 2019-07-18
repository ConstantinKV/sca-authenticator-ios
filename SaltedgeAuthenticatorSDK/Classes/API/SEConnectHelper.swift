//
//  SEConnectHelper.swift
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

public struct SEConnectHelper {
    public static func сonfiguration(from url: URL) -> URL? {
        guard let query = url.queryItem(for: SENetKeys.configuration) else { return nil }

        return URL(string: query)
    }

    public static func skipOrHandleRedirect(url: URL, success: @escaping ((AccessToken) -> ()), failure: @escaping ((String) -> ())) -> Bool {
        guard SENetConstants.hasRedirectUrl(url.absoluteString) else { return true }

        guard let accessToken = url.queryItem(for: SENetKeys.accessToken) else {
            failure(url.queryItem(for: SENetKeys.errorClass) ?? "Something went wrong.")
            return true
        }

        success(accessToken)

        return false
    }
}
