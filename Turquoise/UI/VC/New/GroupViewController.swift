//
//  GroupViewController.swift
//  Turquoise
//
//  Created by tolga on 7/15/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

class GroupViewController : UIViewController {
    let groupManager: GroupManager
    var tableView: UITableView!
    let groupViewModel: GroupTableViewDataSource

    init(groupManager: GroupManager) {
        self.groupManager = groupManager
        self.groupViewModel = GroupTableViewDataSource(groupManager: self.groupManager)

        self.tableView = UITableView()
        self.tableView.register(TQArticleHeaderTableViewCell.self,
                                forCellReuseIdentifier: TQArticleHeaderTableViewCell.reuseId)
        self.tableView.register(UITableViewCell.self,
                                forCellReuseIdentifier: GroupTableViewDataSource.loadingCellReuseId)
        self.tableView.dataSource = self.groupViewModel
        self.tableView.delegate = self.groupViewModel
        self.tableView.backgroundColor = .clear
        self.tableView.translatesAutoresizingMaskIntoConstraints = false

        super.init(nibName: nil, bundle: nil)

        self.groupViewModel.updateCallback = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        self.groupViewModel.articleSelectionCallback = { [weak self] (articleHeaders, indexPath) in
            DispatchQueue.main.async {
                self?.showArticleVC(with: articleHeaders)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: true)

        self.view.addSubview(self.tableView)

        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        self.view.backgroundColor = .black

        let settingsButton = UIBarButtonItem(image: UIImage(named: "settings-16"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(settingsButtonTapped))
        let composeButton = UIBarButtonItem(image: UIImage(named: "compose-16"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(composeButtonTapped))
        self.navigationItem.rightBarButtonItems = [settingsButton, composeButton]

        self.navigationItem.title = self.groupManager.groupId
    }

    private func showArticleVC(with articleHeaders: ArticleHeaders) {
        guard let articleManager = ArticleManager(articleHeaders: articleHeaders,
                                                  groupManager: self.groupManager) else {
            printError("Could not create article manager.")
            return
        }

        let articleVCDataSource = ArticleViewDataSource(articleHeaders: articleHeaders, articleManager: articleManager)
        let articleVC = ArticleViewController(dataSource: articleVCDataSource, groupManager: self.groupManager)
        self.navigationController?.pushViewController(articleVC, animated: true)
    }

    @objc func settingsButtonTapped() {
        let settingsVC = SettingsViewController()
        self.present(settingsVC, animated: true, completion: nil)
    }

    @objc func composeButtonTapped() {
        print("composeButtonTapped")
    }

    private func refreshGroupHeaders() {
        self.groupManager.downloadGroupHeaders()
    }
}
