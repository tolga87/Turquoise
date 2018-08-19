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
    var showsOnlySubscribedGroups: Bool { get set }

    var updateCallback: (() -> Void)? { get set }
    var groupSelectionCallback: ((String) -> Void)? { get set }

    func filter(term: String)
    func reloadData()
}

class GroupSelectorViewModel: NSObject, GroupSelectorViewModelInterface {
    var showsOnlySubscribedGroups = true

    let loadingCellReuseId: String = "GroupSelectorLoadingCell"
    let groupInfoCellReuseId: String = "GroupSelectorGroupInfoCell"

    var updateCallback: (() -> Void)?
    var groupSelectionCallback: ((String) -> Void)?

    private let subscriptionManager: SubscriptionManagerInterface
    private let groupListManager: GroupListManager
    private var groupInfos: [Group]?
    private var filteredGroupInfos: [Group]?
    private var filterBy: String

    init(usenetClient: UsenetClientInterface, subscriptionManager: SubscriptionManagerInterface) {
        self.groupListManager = GroupListManager(usenetClient: usenetClient)
        self.subscriptionManager = subscriptionManager
        self.filterBy = ""
        super.init()

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [
            NSAttributedString.Key.font: UIFont.defaultFont(ofSize: 12.0),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }

    private func numberOfGroups() -> Int? {
        let isFiltering = !self.filterBy.isEmpty
        return isFiltering ? self.filteredGroupInfos?.count : self.groupInfos?.count
    }

    private func groupDescriptionAtIndex(_ index: Int) -> String {
        let groupInfo = self.groupInfoAtIndex(index)
        return "\(groupInfo.groupId) (\(groupInfo.numberOfArticles))"
    }

    private func groupInfoAtIndex(_ index: Int) -> Group {
        let isFiltering = !self.filterBy.isEmpty

        guard
            let infos = isFiltering ? self.filteredGroupInfos : self.groupInfos,
            index < infos.count else {
                fatalError("Invalid index in GroupSelectorViewModel.")
        }

        return infos[index]
    }

    func reloadData() {
        self.groupListManager.downloadGroupList { (groupInfos) in
            if self.showsOnlySubscribedGroups {
                self.groupInfos = groupInfos?.filter { groupInfo in
                    return self.subscriptionManager.isSubscribed(toGroup: groupInfo.groupId)
                }
            } else {
                self.groupInfos = groupInfos
            }

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
            cell.textLabel?.textColor = .lightGray
            cell.textLabel?.font = .defaultFont(ofSize: 14)
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = "Loading..."
            cell.selectionStyle = .none
            cell.accessoryType = .none
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: self.groupInfoCellReuseId, for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .defaultFont(ofSize: 12)

        cell.textLabel?.text = self.groupDescriptionAtIndex(indexPath.row)

        let groupId = self.groupInfoAtIndex(indexPath.row).groupId
        let isSubscribed = self.subscriptionManager.isSubscribed(toGroup: groupId)
        let shouldHighlightSubscriptions = !self.showsOnlySubscribedGroups

        cell.accessoryType = isSubscribed && shouldHighlightSubscriptions ? .checkmark : .none
        return cell
    }
}

extension GroupSelectorViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupId = self.groupInfoAtIndex(indexPath.row).groupId

        self.groupSelectionCallback?(groupId)

//        let isSubscribed = self.subscriptionManager.isSubscribed(toGroup: groupId)
//        if isSubscribed {
//            self.subscriptionManager.unsubscribe(fromGroup: groupId)
//        } else {
//            self.subscriptionManager.subscribe(toGroup: groupId)
//        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let _ = self.numberOfGroups() {
            return indexPath
        } else {
            return nil
        }
    }
}
