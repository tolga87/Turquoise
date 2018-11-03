//
//  MainCoordinator.swift
//  Turquoise
//
//  Created by tolga on 11/3/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
    private let presenter: UIViewController

    required init(presenter: UIViewController) {
        self.presenter = presenter

        // TODO: This is a temporary fix until I implement a proper reconnecting mechanism.
        BackgroundTimeManager.sharedInstance.addObserver(withDelay: 60) {
            self.restart()
        }
    }

    func start() {
        let loginViewController = LoginViewController()
        loginViewController.autoLogin = true
        self.presenter.present(loginViewController, animated: false, completion: nil)
    }

    @objc func didLogout() {
        self.restart()
    }

    private func restart() {
        if self.presenter.presentedViewController != nil {
            self.presenter.dismiss(animated: false, completion: nil)
            self.start()
        }
    }
}
