//
//  GroupSelectorViewController.swift
//  Turquoise
//
//  Created by tolga on 2/3/19.
//  Copyright © 2019 Tolga AKIN. All rights reserved.
//

import UIKit

class GroupSelectorViewController: UITableViewController {
    var viewModel: NewsgroupsListViewModelInterface? {
        didSet {
            viewModel?.groupInfoUpdateCallback = { [weak self] in
                self?.reloadData()
            }
            self.reloadData()
        }
    }
    private let searchController: UISearchController

    init(title: String?, viewModel: NewsgroupsListViewModelInterface? = nil) {
        self.viewModel = viewModel
        self.searchController = UISearchController(searchResultsController: nil)

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [
            NSAttributedString.Key.font: UIFont.defaultFont(ofSize: 12.0),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]

        super.init(nibName: nil, bundle: nil)

        self.title = title
        self.viewModel?.groupInfoUpdateCallback = { [weak self] in
            self?.reloadData()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black
        self.tableView.indicatorStyle = .white

        // Show search bar if we don't have a viewModel (loading...)
        let shouldHideSearchBar = (self.viewModel?.shouldShowSearchBar == false)
        if !shouldHideSearchBar {
            self.searchController.searchResultsUpdater = self
            self.searchController.obscuresBackgroundDuringPresentation = false
            self.searchController.searchBar.placeholder = "Search newsgroups"
            self.searchController.searchBar.autocapitalizationType = .none
            self.searchController.hidesNavigationBarDuringPresentation = false
            self.navigationItem.searchController = searchController
            self.navigationItem.hidesSearchBarWhenScrolling = false
            self.definesPresentationContext = true
        }
        self.updateSearchBar()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Consts.groupCellReuseId)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Consts.manageCellReuseId)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Consts.loadingCellReuseId)
        self.tableView.tableFooterView = UIView()
    }

    public func reloadData() {
        self.updateSearchBar()
        self.tableView.reloadData()
    }

    private func updateSearchBar() {
        self.searchController.searchBar.isUserInteractionEnabled = (self.viewModel?.shouldShowSearchBar == true)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return GroupSelectorTableViewSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = GroupSelectorTableViewSection(rawValue: section) else { return 0 }

        switch section {
        case .loading:
            return self.viewModel == nil ? 1 : 0
        case .manage:
            guard let viewModel = self.viewModel else {
                return 0
            }

            return viewModel.shouldShowManageButton ? 1 : 0
        case .group:
            guard let viewModel = self.viewModel else {
                return 0
            }

            return viewModel.numberOfNewsgroups()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = GroupSelectorTableViewSection(rawValue: indexPath.section) else { return UITableViewCell() }

        let cell: UITableViewCell
        switch section {
        case .loading:
            let loadingCell = tableView.dequeueReusableCell(withIdentifier: Consts.loadingCellReuseId, for: indexPath)
            loadingCell.backgroundColor = .clear
            loadingCell.textLabel?.textColor = .white
            loadingCell.textLabel?.font = .defaultFont(ofSize: 12)
            loadingCell.textLabel?.text = "Loading..."
            loadingCell.selectionStyle = .none
            cell = loadingCell

        case .manage:
            let manageCell = tableView.dequeueReusableCell(withIdentifier: Consts.manageCellReuseId, for: indexPath)
            manageCell.backgroundColor = .clear
            manageCell.textLabel?.textColor = UIColor.tq_lightGray
            manageCell.textLabel?.font = .defaultFont(ofSize: 11)
            manageCell.textLabel?.text = "Manage Subscriptions..."
            cell = manageCell

        case .group:
            guard let viewModel = self.viewModel else {
                assertionFailure("Cannot show group button with nil viewModel.")
                return UITableViewCell()
            }

            let groupCell = tableView.dequeueReusableCell(withIdentifier: Consts.groupCellReuseId, for: indexPath)
            groupCell.backgroundColor = .clear
            groupCell.textLabel?.textColor = .white
            groupCell.textLabel?.font = .defaultFont(ofSize: 12)

            let newsgroupTitlePresentable = viewModel.titleForNewsgroup(atIndex: indexPath.row)
            let title: String
            if let numberOfMessages = newsgroupTitlePresentable.numberOfMessages {
                title = "\(newsgroupTitlePresentable.groupId) (\(numberOfMessages))"
            } else {
                title = newsgroupTitlePresentable.groupId
            }

            groupCell.textLabel?.text = title
            groupCell.accessoryType = newsgroupTitlePresentable.isChecked ? .checkmark : .none
            cell = groupCell
        }

        cell.backgroundColor = indexPath.isEven() ? UIColor.tq_veryDarkGray : UIColor.tq_darkBlue
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = GroupSelectorTableViewSection(rawValue: section), section == .group else { return nil }

        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor.tq_veryDarkGray

        let header = UIView()
        header.addSubview(separator)

        separator.leadingAnchor.constraint(equalTo: header.leadingAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: header.trailingAnchor).isActive = true
        separator.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = GroupSelectorTableViewSection(rawValue: section), section == .group else { return 0 }

        return 2.0
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let section = GroupSelectorTableViewSection(rawValue: indexPath.section), section == .loading {
            // Do not allow the `Loading` cell to be selected.
            return nil
        } else {
            return indexPath
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = GroupSelectorTableViewSection(rawValue: indexPath.section) else { return }

        switch section {
        case .loading:
            // This should not happen.
            break

        case .manage:
            guard let viewModel = self.viewModel else {
                assertionFailure("Cannot show manage button with nil viewModel.")
                return
            }
            viewModel.didSelectManage()

        case .group:
            guard let viewModel = self.viewModel else {
                assertionFailure("Cannot show group button with nil viewModel.")
                return
            }
            viewModel.didSelectNewsgroup(atIndex: indexPath.row)
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension GroupSelectorViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.viewModel?.filterTerm = searchController.searchBar.text?.tq_whitespaceAndNewlineStrippedString
    }
}

private extension GroupSelectorViewController {
    struct Consts {
        static let groupCellReuseId = "groupCellReuseId"
        static let manageCellReuseId = "manageCellReuseId"
        static let loadingCellReuseId = "loadingCellReuseId"
    }
}

private enum GroupSelectorTableViewSection: Int, CaseIterable {
    case loading = 0
    case manage = 1
    case group = 2
}
