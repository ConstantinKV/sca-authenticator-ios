//
//  AuthorizationsDataSourceSpec.swift
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

import Quick
import Nimble
@testable import SEAuthenticator

class AuthorizationsDataSourceSpec: BaseSpec {
    override func spec() {
        var firstModel, secondModel: AuthorizationViewModel!
        let dataSource = AuthorizationsDataSource()

        beforeEach {
            let connection = Connection()
            connection.id = "12345"
            ConnectionRepository.save(connection)
            _ = SECryptoHelper.createKeyPair(with: SETagHelper.create(for: connection.guid))

            let authMessage = ["id": "00000",
                               "connection_id": connection.id,
                               "title": "Authorization",
                               "description": "Test authorization",
                               "created_at": Date().iso8601string,
                               "expires_at": Date().addingTimeInterval(5.0 * 60.0).iso8601string]

            let secondAuthMessage = ["id": "00001",
                                     "connection_id": connection.id,
                                     "title": "Second Authorization",
                                     "description": "Test authorization",
                                     "created_at": Date().iso8601string,
                                     "expires_at": Date().addingTimeInterval(5.0 * 60.0).iso8601string]
            
            let encryptedData = try! SECryptoHelper.encrypt(authMessage.jsonString!, tag: SETagHelper.create(for: connection.guid))
            let secondEncryptedData = try! SECryptoHelper.encrypt(
                secondAuthMessage.jsonString!, tag: SETagHelper.create(for: connection.guid)
            )
            
            let dict = [
                "data": encryptedData.data,
                "key": encryptedData.key,
                "iv": encryptedData.iv,
                "connection_id": connection.id,
                "algorithm": "AES-256-CBC"
            ]

            let secondDict = [
                "data": secondEncryptedData.data,
                "key": secondEncryptedData.key,
                "iv": secondEncryptedData.iv,
                "connection_id": connection.id,
                "algorithm": "AES-256-CBC"
            ]

            let firstResponse = SEEncryptedAuthorizationResponse(dict)!
            let secondResponse = SEEncryptedAuthorizationResponse(secondDict)!

            let firstDecryptedData: SEDecryptedAuthorizationData = AuthorizationsPresenter.decryptedData(from: firstResponse)!
            let secondDecryptedData: SEDecryptedAuthorizationData = AuthorizationsPresenter.decryptedData(from: secondResponse)!

            firstModel = AuthorizationViewModel(firstDecryptedData)
            secondModel = AuthorizationViewModel(secondDecryptedData)

            _ = dataSource.update(with: [firstDecryptedData, secondDecryptedData])
        }

        describe("sections") {
            it("should return numer of sections, that is equal to number of authorizations") {
                expect(dataSource.sections).to(equal(1))
            }
        }

        describe("hasDataToShow") {
            it("should return true") {
                expect(dataSource.hasDataToShow).to(beTrue())
            }
        }

        describe("rows(for)") {
            it("should always return 1") {
                expect(dataSource.rows).to(equal(2))
            }
        }

        describe("remove(_:)") {
            context("when view model exists") {
                it("should remove it from array and as a result return it's index") {
                    expect(dataSource.rows).to(equal(2))
                    expect(dataSource.remove(firstModel)).to(equal(0))
                    expect(dataSource.rows).to(equal(1))
                }
            }
 
            context("when view model doesn't exist") {
                it("should return nil") {
                    let secondAuthMessage = ["id": "123343543535",
                                             "connection_id": "113223",
                                             "title": "Zombie Authorization",
                                             "description": "Not existed",
                                             "created_at": Date().iso8601string,
                                             "expires_at": Date().addingTimeInterval(5.0 * 60.0).iso8601string]
                    let decryptedData = SEDecryptedAuthorizationData(secondAuthMessage)!

                    expect(dataSource.remove(AuthorizationViewModel(decryptedData)!)).to(beNil())
                }
            }
        }

        describe("viewModel(at)") {
            context("when viewModel exists") {
                it("should return viewModel for given index") {
                    expect(dataSource.viewModel(at: 1)).to(equal(secondModel))
                }
            }

            context("when viewModel doesn't exist at given index") {
                it("should return nil") {
                    expect(dataSource.viewModel(at: 5)).to(beNil())
                }
            }
        }

        describe("viewModel(by:)") {
            context("when one of existed viewModels has connectionId and authorizationId equal for given params") {
                it("should return existed viewModel") {                
                    expect(dataSource.viewModel(by: "12345", authorizationId: "00000")).to(equal(firstModel))
                }
            }

            context("when given parameters doesn't suit any of existed viewModels") {
                it("should return nil") {
                    expect(dataSource.viewModel(by: "09876", authorizationId: "1234565657575")).to(beNil())
                }
            }
        }

        describe("index(of)") {
            context("when viewModel exists") {
                it("should return index of given viewModel") {
                    expect(dataSource.index(of: firstModel)).to(equal(0))
                }
            }

            context("when authorization doesn't exist") {
                it("should return nil") {
                    let secondAuthMessage = ["id": "123343543535",
                                             "connection_id": "113223",
                                             "title": "Zombie Authorization",
                                             "description": "Not existed",
                                             "created_at": Date().iso8601string,
                                             "expires_at": Date().addingTimeInterval(5.0 * 60.0).iso8601string]
                    let decryptedData = SEDecryptedAuthorizationData(secondAuthMessage)!
                    
                    expect(dataSource.index(of: AuthorizationViewModel(decryptedData)!)).to(beNil())
                }
            }
        }

        describe("item(for)") {
            it("should return view model for given index") {
                expect(dataSource.viewModel(at: 0)).to(equal(firstModel))
                expect(dataSource.viewModel(at: 1)).to(equal(secondModel))
            }
        }
    }
}
