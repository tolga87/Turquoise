//
//  ArticleComposerViewController.swift
//  Turquoise
//
//  Created by tolga on 7/28/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

class ArticleComposerViewController: UITableViewController {
    let viewModel: ArticleComposerViewModelInterface

    init(viewModel: ArticleComposerViewModelInterface) {
        self.viewModel = viewModel
        super.init(style: .plain)

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
        self.tableView.register(ArticleComposerSubjectCell.self, forCellReuseIdentifier: ArticleComposerSubjectCell.reuseId)
        self.tableView.register(ArticleComposerBodyCell.self, forCellReuseIdentifier: ArticleComposerBodyCell.reuseId)
        self.tableView.dataSource = self.viewModel
        self.tableView.delegate = self.viewModel
        self.tableView.tableFooterView = UIView()
        self.tableView.bounces = false
        self.tableView.allowsSelection = false
    }

    @objc private func didTapCancel() {
        self.viewModel.cancel()
    }

    @objc private func didTapSend() {
        self.viewModel.accept()
    }
}
