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

    init(usenetClient: UsenetClientInterface, groupManager: GroupManager) {
        self.groupManager = groupManager
        self.groupViewModel = GroupTableViewDataSource(groupManager: self.groupManager)

        self.tableView = UITableView()
        self.tableView.register(TQArticleHeaderTableViewLoadingCell.self,
                                forCellReuseIdentifier: TQArticleHeaderTableViewLoadingCell.reuseId)
        self.tableView.register(TQArticleHeaderTableViewCell.self,
                                forCellReuseIdentifier: TQArticleHeaderTableViewCell.reuseId)
        self.tableView.dataSource = self.groupViewModel
        self.tableView.delegate = self.groupViewModel
        self.tableView.backgroundColor = .clear
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.tableFooterView = UIView()

        super.init(nibName: nil, bundle: nil)

        ReadArticleManager.sharedInstance.delegate = self

        self.groupViewModel.updateCallback = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        self.groupViewModel.progressUpdateCallback = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadSections(IndexSet(integer: 0), with: .none)
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

    @objc func composeButtonTapped() {
        let articleComposerViewModel = ArticleComposerViewModel(groupManager: self.groupManager)
        let articleComposer = ArticleComposerViewController(viewModel: articleComposerViewModel)
        let navController = UINavigationController(rootViewController: articleComposer)
        navController.navigationBar.barTintColor = .clear
        self.present(navController, animated: true, completion: nil)
    }

    @objc func settingsButtonTapped() {
        let settingsViewModel = SettingsViewModel(options: [
            SettingOption(title: "Manage Newsgroup Subscriptions") {
                self.executeAfterDismissal {
                    // TODO: Implement.
                }
            },
            SettingOption(title: "Mark All as Read") {
                self.executeAfterDismissal { [weak self] in
                    self?.groupManager.markAllAsRead()
                }
            },
            SettingOption(title: "Logout") {
                self.executeAfterDismissal {
                    // TODO: Implement.
                }
            }])
        let settingsVC = SettingsViewController(viewModel: settingsViewModel)
        self.present(DismissableViewController(rootViewController: settingsVC), animated: true, completion: nil)
    }

    private func executeAfterDismissal(block: @escaping () -> Void) {
        if let _ = self.presentingViewController {
            self.dismiss(animated: true) {
                block()
            }
        } else {
            block()
        }
    }

    private func refreshGroupHeaders() {
        self.groupManager.downloadGroupHeaders()
    }
}

extension GroupViewController: ArticleReadStatusChangeHandler {
    func articleDidMarkAsRead(_ messageId: String) {
        self.tableView.reloadData()
    }

    func articleDidMarkAsUnread(_ messageId: String) {
        self.tableView.reloadData()
    }

    func articlesDidUpdate() {
        self.tableView.reloadData()
    }
}

