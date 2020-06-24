//
//  DecryptHelper.swift
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2020 Salt Edge Inc.
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

 extension SEEncryptedData {
    func decryptAuthorizationData() -> SEAuthorizationData? {
        if let connectionId = self.connectionId,
            let connection = ConnectionsCollector.with(id: connectionId) {
            do {
                let decryptedData = try SECryptoHelper.decrypt(self, tag: SETagHelper.create(for: connection.guid))

                guard let decryptedDictionary = decryptedData.json else { return nil }

                return SEAuthorizationData(decryptedDictionary)
            } catch {
                return nil
            }
        }
        return nil
    }

    func decryptConsentData() -> SEConsentData? {
        if let connectionId = self.connectionId,
            let connection = ConnectionsCollector.with(id: connectionId) {
            do {
                let decryptedData = try SECryptoHelper.decrypt(self, tag: SETagHelper.create(for: connection.guid))

                guard let decryptedDictionary = decryptedData.json else { return nil }

                return SEConsentData(decryptedDictionary)
            } catch {
                return nil
            }
        }
        return nil
    }
}
