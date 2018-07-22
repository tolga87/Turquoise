//
//  LoginManager.swift
//  Turquoise
//
//  Created by tolga on 7/8/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

class LoginManager {

    private var usenetClient: UsenetClientInterface

    var loginSuccessCallback: (() -> Void)?
    var loginFailureCallback: (() -> Void)?

    init(usenetClient: UsenetClientInterface) {
        self.usenetClient = usenetClient
    }

    func login(userName: String, password: String) {
        // TODO: check inputs

        let authUserRequest = NNTPRequest(string: "AUTHINFO USER \(userName)\r\n")
        self.usenetClient.makeRequest(authUserRequest) { (response) in
            guard let response = response else {
                self.loginFailureCallback?()
                return
            }

            // This can happen if we are already logged in and trying to log in again.
            if response.isAlreadyAuthenticated() {
                self.loginSuccessCallback?()
                return
            }

            guard response.okSoFar() else {
                self.loginFailureCallback?()
                return
            }

            let authPassRequest = NNTPRequest(string: "AUTHINFO PASS \(password)\r\n")
            self.usenetClient.makeRequest(authPassRequest, completion: { (response) in
                guard let response = response, response.ok() else {
                    self.loginFailureCallback?()
                    return
                }

                self.loginSuccessCallback?()
            })
        }
    }
}
