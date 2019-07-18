//
//  SEEncryptedAuthorizationResponse.swift
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

public struct SEEncryptedData: SerializableResponse {
    public let data: String
    public let key: String
    public let iv: String

    public init(data: String, key: String, iv: String) {
        self.data = data
        self.key = key
        self.iv = iv
    }

    public init?(_ value: Any) {
        if let dict = value as? [String: Any],
            let data = dict[SENetKeys.data] as? String,
            let key = dict[SENetKeys.key] as? String,
            let iv = dict[SENetKeys.iv] as? String {
            self.data = data
            self.key = key
            self.iv = iv
        } else {
            return nil
        }
    }
}

public struct SEEncryptedAuthorizationResponse: SerializableResponse, Equatable {
    private let defaultAlgorithm = "AES-256-CBC"

    public let data: String
    public let key: String
    public let iv: String
    public var connectionId: String?

    public init?(_ value: Any) {
        if let dict = value as? [String: Any],
            let data = dict[SENetKeys.data] as? String,
            let key = dict[SENetKeys.key] as? String,
            let iv = dict[SENetKeys.iv] as? String,
            let algorithm = dict[SENetKeys.algorithm] as? String,
            algorithm == defaultAlgorithm {
            self.data = data
            self.key = key
            self.iv = iv
            if let connectionId = dict[SENetKeys.connectionId] as? String {
                self.connectionId = connectionId
            }
        } else {
            return nil
        }
    }

    public static func == (lhs: SEEncryptedAuthorizationResponse, rhs: SEEncryptedAuthorizationResponse) -> Bool {
        return lhs.data == rhs.data &&
            lhs.key == rhs.key &&
            lhs.iv == rhs.iv &&
            lhs.connectionId == rhs.connectionId
    }
}

public struct SEAuthorizationResponse: SerializableResponse {
    public var data: SEEncryptedAuthorizationResponse

    public init?(_ value: Any) {
        if let response = (value as AnyObject)[SENetKeys.data] as? [String: Any],
            let data = SEEncryptedAuthorizationResponse(response) {
            self.data = data
        } else {
            return nil
        }
    }
}

public struct SEAuthorizationsResponse: SerializableResponse {
    public var data: [SEEncryptedAuthorizationResponse] = []

    public init?(_ value: Any) {
        if let responses = (value as AnyObject)[SENetKeys.data] as? [[String: Any]] {
            self.data = responses.compactMap { SEEncryptedAuthorizationResponse($0) }
        } else {
            return nil
        }
    }
}
