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

    init(viewModel: GroupSelectorViewModel) {
        self.viewModel = viewModel
        self.searchController = UISearchController(searchResultsController: nil)

        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadData() {
        self.tableView.reloadData()
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
