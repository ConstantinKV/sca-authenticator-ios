//
//  SingleAuthorizationViewController
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

import UIKit

final class SingleAuthorizationViewController: BaseViewController {
    private let authorizationView = AuthorizationView()

    init(connectionId: String, authorizationId: String) {
        super.init(nibName: nil, bundle: .authenticator_main)
        let viewModel = AuthorizationsViewModel()
        viewModel.delegate = self

        let dataSource = AuthorizationsDataSource()
        viewModel.dataSource = dataSource
        viewModel.singleAuthorization = (connectionId: connectionId, authorizationId: authorizationId)
        authorizationView.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }

    func layout() {
        view.addSubview(authorizationView)

        authorizationView.edgesToSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AuthorizationsViewModelEventsDelegate
extension SingleAuthorizationViewController: AuthorizationsViewModelEventsDelegate {
    func reloadData() {
        authorizationView.reloadData()
    }

    func scroll(to index: Int) {
        authorizationView.scroll(to: index)
    }

    func shouldDismiss() {
        close()
    }
}
