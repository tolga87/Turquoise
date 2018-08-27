//
//  ArticleComposerViewController.swift
//  Turquoise
//
//  Created by tolga on 7/28/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

class ArticleComposerViewController: UIViewController {
    let viewModel: ArticleComposerViewModelInterface

    private var subjectField: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.horizontalInset = 4
        field.fontSize = 14
        field.textColor = .white
        field.attributedPlaceholder = NSAttributedString(string: "Subject", attributes: [.foregroundColor : UIColor.darkGray])
        field.borderColor = UIColor(black: 0.80)
        field.borderWidth = 1
        field.cornerRadius = 2
        return field
    }()

    private var bodyField: UITextView = {
        let field = UITextView()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.font = UIFont.defaultFont(ofSize: 12)
        field.backgroundColor = .clear
        field.textColor = UIColor(white: 0.85, alpha: 1)
        field.borderColor = UIColor(black: 0.80)
        field.borderWidth = 1
        field.cornerRadius = 2
        return field
    }()

    private var sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .defaultFont(ofSize: 12)
        button.setTitle("SEND", for: .normal)
        button.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        return button
    }()

    private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .white)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()

    init(viewModel: ArticleComposerViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        self.viewModel.completionBlock = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black

        let cancelButtonItem = UIBarButtonItem(image: UIImage(named: "close-32"),
                                               style: .plain,
                                               target: self,
                                               action: #selector(didTapCancel))
        self.navigationItem.leftBarButtonItem = cancelButtonItem

        self.sendButton.setTitleColor(self.view.tintColor, for: .normal)
        self.sendButton.setTitleColor(self.view.tintColor.withAlphaComponent(0.7), for: .highlighted)
        self.sendButton.setTitleColor(UIColor.lightGray, for: .disabled)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.sendButton)

        self.sendButton.addSubview(self.spinner)
        self.spinner.centerXAnchor.constraint(equalTo: self.sendButton.centerXAnchor).isActive = true
        self.spinner.centerYAnchor.constraint(equalTo: self.sendButton.centerYAnchor).isActive = true
        self.spinner.widthAnchor.constraint(equalToConstant: 20).isActive = true
        self.spinner.heightAnchor.constraint(equalToConstant: 20).isActive = true

        self.view.addSubview(self.subjectField)
        self.subjectField.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor,
                                                   constant: Consts.horizontalPadding).isActive = true
        self.subjectField.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor,
                                                    constant: -Consts.horizontalPadding).isActive = true
        self.subjectField.topAnchor.constraint(equalTo: self.view.safeTopAnchor,
                                               constant: Consts.verticalPadding).isActive = true
        self.subjectField.heightAnchor.constraint(equalToConstant: Consts.subjectFieldHeight).isActive = true

        self.view.addSubview(self.bodyField)
        self.bodyField.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor,
                                                constant: Consts.horizontalPadding).isActive = true
        self.bodyField.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor,
                                                 constant: -Consts.horizontalPadding).isActive = true
        self.bodyField.topAnchor.constraint(equalTo: self.subjectField.bottomAnchor,
                                            constant: Consts.verticalPadding).isActive = true
        self.bodyField.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor,
                                               constant: -Consts.verticalPadding).isActive = true

        self.subjectField.text = self.viewModel.subject
        self.bodyField.text = self.viewModel.body ?? ""
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.bodyField.becomeFirstResponder()
        self.bodyField.selectedRange = NSRange(location: 0, length: 0)
    }

    @objc private func didTapCancel() {
        self.viewModel.cancel()
    }

    @objc private func didTapSend() {
        guard let subject = self.subjectField.text, let body = self.bodyField.text else {
            return
        }

        let sanitizedSubject = subject.tq_whitespaceAndNewlineStrippedString
        let sanitizedBody = body.tq_whitespaceAndNewlineStrippedString
        guard !sanitizedSubject.isEmpty, !sanitizedBody.isEmpty else {
            return
        }

        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.view.isUserInteractionEnabled = false
        self.spinner.startAnimating()
        self.viewModel.accept(subject: sanitizedSubject, body: sanitizedBody)
    }

    private struct Consts {
        static let horizontalPadding: CGFloat = 8
        static let verticalPadding: CGFloat = 8
        static let subjectFieldHeight: CGFloat = 40
    }
}
