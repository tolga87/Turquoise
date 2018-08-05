//
//  DismissableViewControllerInterface.swift
//  Turquoise
//
//  Created by tolga on 8/5/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

class DismissableViewController: UINavigationController {
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        let dismissButton = UIBarButtonItem(image: UIImage(named: "close-32"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(dismissButtonTapped))
        rootViewController.navigationItem.leftBarButtonItem = dismissButton

        self.navigationBar.barTintColor = .clear
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func dismissButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}
