//
//  UserInfoInputController.swift
//  Turquoise
//
//  Created by tolga on 8/19/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

typealias UserInfoValidationBlock = (String?, String?) -> Bool
typealias UserInfoInputCompletionBlock = (String, String) -> Void

class AlertController: UIAlertController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.traverseSubviews { (subview) in
            guard let label = subview as? UILabel else {
                return
            }

            label.font = .defaultFont(ofSize: 12.0)
        }
    }
}

class UserInfoInputController {
    let message: String
    var completionBlock: UserInfoInputCompletionBlock!

    private var validationBlock: UserInfoValidationBlock
    private weak var proceedAction: UIAlertAction?
    private weak var nameField: UITextField?
    private weak var emailField: UITextField?

    init(message: String) {
        self.message = message

        self.validationBlock = { (name, email) in
            guard
                let name = name,
                let email = email,
                !name.tq_isEmpty,
                !email.tq_isEmpty else {
                    return false
            }
            return true
        }

        UITextField.appearance(whenContainedInInstancesOf: [AlertController.self]).defaultTextAttributes = [
            NSAttributedString.Key.font: UIFont.defaultFont(ofSize: 12.0)
        ]
    }

    func show(in presentingViewController: UIViewController) {
        guard let completionBlock = self.completionBlock else {
            return
        }

        let alertController = AlertController(title: nil, message: self.message, preferredStyle: .alert)
        alertController.view.tintColor = .black

        alertController.addTextField(configurationHandler: { (nameField) in
            nameField.placeholder = "Name"
            nameField.addTarget(self, action: #selector(self.nameTextChanged(_:)), for: .editingChanged)
            self.nameField = nameField
        })
        alertController.addTextField(configurationHandler: { (emailField) in
            emailField.placeholder = "Email"
            emailField.addTarget(self, action: #selector(self.emailTextChanged(_:)), for: .editingChanged)
            self.emailField = emailField
        })

        let proceedAction = UIAlertAction(title: "Proceed", style: .default, handler: { (_) in
            let nameValue = self.nameField?.text ?? ""
            let emailValue = self.emailField?.text ?? ""
            completionBlock(nameValue, emailValue)
        })
        proceedAction.isEnabled = false

        alertController.addAction(proceedAction)
        self.proceedAction = proceedAction

        presentingViewController.present(alertController, animated: true) { }
    }

    @objc
    func nameTextChanged(_ textField: UITextField) {
        let isInputValid = self.validationBlock(self.nameField?.text, self.emailField?.text)
        self.proceedAction?.isEnabled = isInputValid
    }

    @objc
    func emailTextChanged(_ textField: UITextField) {
        let isInputValid = self.validationBlock(self.nameField?.text, self.emailField?.text)
        self.proceedAction?.isEnabled = isInputValid
    }
}
