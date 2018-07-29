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
        field.horizontalInset = 4
        field.fontSize = 14
        field.textColor = .white
        field.borderColor = UIColor(black: 0.80)
        field.borderWidth = 1
        field.cornerRadius = 2
        return field
    }()

    private var bodyField: UITextView = {
        let field = UITextView()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = UIFont.defaultFont(ofSize: 12)
        field.backgroundColor = .clear
        field.textColor = UIColor(white: 0.85, alpha: 1)
        field.borderColor = UIColor(black: 0.80)
        field.borderWidth = 1
        field.cornerRadius = 2
        return field
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

        let cancelButtonItem = UIBarButtonItem(image: UIImage(named: "close-32"),
                                               style: .plain,
                                               target: self,
                                               action: #selector(didTapCancel))
        self.navigationItem.leftBarButtonItem = cancelButtonItem

        let sendButtonItem = UIBarButtonItem(title: "SEND",
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapSend))
        self.navigationItem.rightBarButtonItem = sendButtonItem

        self.view.backgroundColor = .black

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

//        self.tableView.register(ArticleComposerSubjectCell.self, forCellReuseIdentifier: ArticleComposerSubjectCell.reuseId)
//        self.tableView.register(ArticleComposerBodyCell.self, forCellReuseIdentifier: ArticleComposerBodyCell.reuseId)
//        self.tableView.dataSource = self.viewModel
//        self.tableView.delegate = self.viewModel
//        self.tableView.tableFooterView = UIView()
//        self.tableView.bounces = false
//        self.tableView.allowsSelection = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.bodyField.becomeFirstResponder()
    }

    @objc private func didTapCancel() {
        self.viewModel.cancel()
    }

    @objc private func didTapSend() {
        self.viewModel.accept()
    }

    private struct Consts {
        static let horizontalPadding: CGFloat = 8
        static let verticalPadding: CGFloat = 8
        static let subjectFieldHeight: CGFloat = 40
    }
}
