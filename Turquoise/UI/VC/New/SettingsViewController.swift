//
//  SettingsViewController.swift
//  Turquoise
//
//  Created by tolga on 7/22/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    lazy var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false

        let settingsNavigationItem = UINavigationItem(title: "Settings")
        settingsNavigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close-32"),
                                                                    style: .plain,
                                                                    target: self,
                                                                    action: #selector(dismissButtonTapped))
        navigationBar.items = [settingsNavigationItem]
        return navigationBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)

        self.view.addSubview(self.navigationBar)

        self.navigationBar.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor).isActive = true
        self.navigationBar.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor).isActive = true
        self.navigationBar.topAnchor.constraint(equalTo: self.view.safeTopAnchor).isActive = true
        self.navigationBar.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }

    func dismissButtonTapped() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
