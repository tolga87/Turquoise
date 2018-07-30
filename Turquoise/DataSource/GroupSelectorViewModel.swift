//
//  GroupSelectorViewModel.swift
//  Turquoise
//
//  Created by tolga on 7/29/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

protocol GroupSelectorViewModelInterface: UITableViewDataSource, UITableViewDelegate {
    var loadingCellReuseId: String { get }
    var groupInfoCellReuseId: String { get }
    var updateCallback: (() -> Void)? { get set }

    func filter(term: String)
    func reloadData()
}

class GroupSelectorViewModel: NSObject, GroupSelectorViewModelInterface {
    let loadingCellReuseId: String = "GroupSelectorLoadingCell"
    let groupInfoCellReuseId: String = "GroupSelectorGroupInfoCell"

    var updateCallback: (() -> Void)?
    private let groupListManager: GroupListManager
    private var groupInfos: [GroupInfo]?
    private var filteredGroupInfos: [GroupInfo]?
    private var filterBy: String

    init(usenetClient: UsenetClientInterface) {
        self.groupListManager = GroupListManager(usenetClient: usenetClient)
        self.filterBy = ""
        super.init()

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [
            NSAttributedString.Key.font: UIFont.defaultFont(ofSize: 12.0),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }

    func numberOfGroups() -> Int? {
        let isFiltering = !self.filterBy.isEmpty
        return isFiltering ? self.filteredGroupInfos?.count : self.groupInfos?.count
    }

    func groupDescriptionAtIndex(_ index: Int) -> String {
        let isFiltering = !self.filterBy.isEmpty

        guard
            let infos = isFiltering ? self.filteredGroupInfos : self.groupInfos,
            index < infos.count else {
                fatalError("Invalid index in GroupSelectorViewModel.")
        }

        let groupInfo = infos[index]
        return "\(groupInfo.groupId) (\(groupInfo.numberOfArticles))"
    }

    func reloadData() {
        self.groupListManager.downloadGroupList { (groupInfos) in
            self.groupInfos = groupInfos
            self.filterDataIfNecessary()
            self.updateCallback?()
        }
    }

    func filter(term: String) {
        self.filterBy = term
        self.filterDataIfNecessary()
        self.updateCallback?()
    }

    private func filterDataIfNecessary() {
        guard let groupInfos = self.groupInfos else {
            self.filteredGroupInfos = nil
            return
        }
        guard !self.filterBy.isEmpty else {
            self.filteredGroupInfos = self.groupInfos
            return
        }

        self.filteredGroupInfos = groupInfos.filter {
            $0.caseInsensitiveMatches(searchTerm: self.filterBy)
        }
    }
}

extension GroupSelectorViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If number is nil, we haven't finished fetching the list yet.
        return self.numberOfGroups() ?? 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _ = self.numberOfGroups() else {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.loadingCellReuseId, for: indexPath)
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = .defaultFont(ofSize: 12)
            cell.textLabel?.text = "Loading..."
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: self.groupInfoCellReuseId, for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .defaultFont(ofSize: 12)
        cell.textLabel?.text = self.groupDescriptionAtIndex(indexPath.row)
        return cell
    }
}
