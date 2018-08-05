//
//  GroupSelectorViewController.swift
//  Turquoise
//
//  Created by tolga on 7/22/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

class GroupSelectorViewController: UITableViewController {
    let viewModel: GroupSelectorViewModelInterface
    let searchController: UISearchController

    init(usenetClient: UsenetClientInterface, subscriptionManager: SubscriptionManagerInterface) {
        self.viewModel = GroupSelectorViewModel(usenetClient: usenetClient, subscriptionManager: subscriptionManager)
        self.searchController = UISearchController(searchResultsController: nil)
        super.init(style: .plain)

        self.viewModel.updateCallback = {
            self.tableView.reloadData()
        }
        self.viewModel.groupSelectionCallback = { groupId in
            let groupManager = GroupManager(groupId: groupId, usenetClient: usenetClient)
            let groupVC = GroupViewController(usenetClient: usenetClient, groupManager: groupManager)
            self.navigationController?.pushViewController(groupVC, animated: true)
        }

        subscriptionManager.updateCallback = {
            self.tableView.reloadData()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Select Newsgroup to Display"
        self.view.backgroundColor = .black

        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search newsgroups"
        self.searchController.searchBar.autocapitalizationType = .none
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.viewModel.loadingCellReuseId)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.viewModel.groupInfoCellReuseId)
        self.tableView.dataSource = self.viewModel
        self.tableView.delegate = self.viewModel
        self.tableView.tableFooterView = UIView()

        self.viewModel.reloadData()
    }
}

extension GroupSelectorViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let filterTerm = searchController.searchBar.text ?? ""
        self.viewModel.filter(term: filterTerm)
    }
}
