//
//  NewsgroupsListViewModel.swift
//  Turquoise
//
//  Created by tolga on 2/3/19.
//  Copyright © 2019 Tolga AKIN. All rights reserved.
//

import Foundation

protocol NewsgroupsListViewModelInterface {
    var shouldShowSearchBar: Bool { get }
    var shouldShowManageButton: Bool { get }
    var groupSelectionCallback: ((String) -> Void)? { get }
    var groupManagementCallback: (() -> Void)? { get }
    var groupInfoUpdateCallback: (() -> Void)? { get set }

    var filterTerm: String? { get set }
    func numberOfNewsgroups() -> Int
    func titleForNewsgroup(atIndex index: Int) -> NewsgroupTitlePresentable
    func didSelectNewsgroup(atIndex index: Int) -> Void
    func didSelectManage() -> Void
}

enum NewsgroupsListMode {
    case subscribed
    case all
}

class NewsgroupsListViewModel: NewsgroupsListViewModelInterface {
    var shouldShowSearchBar: Bool
    var shouldShowManageButton: Bool
    var groupSelectionCallback: ((String) -> Void)?
    var groupManagementCallback: (() -> Void)?
    var groupInfoUpdateCallback: (() -> Void)?

    var filterTerm: String? {
        didSet {
            self.notifyGroupInfoUpdates()
        }
    }

    private var mode: NewsgroupsListMode
    private var subscriptionManager: SubscriptionManagerInterface
    private var groupListManager: GroupListManagerInterface?
    private var groupTitlePresentables: [NewsgroupTitlePresentable] = []
    private var filteredGroupTitlePresentables: [NewsgroupTitlePresentable] {
        guard let filterTerm = self.filterTerm, !filterTerm.tq_isEmpty else {
            return self.groupTitlePresentables
        }

        return self.groupTitlePresentables.filter { presentable in
            presentable.groupId.lowercased().contains(filterTerm.lowercased())
        }
    }

    init(mode: NewsgroupsListMode,
         subscriptionManager: SubscriptionManagerInterface,
         groupListManager: GroupListManagerInterface? = nil,
         shouldShowSearchBar: Bool = false,
         shouldShowManageButton: Bool = false) {

        self.mode = mode
        self.subscriptionManager = subscriptionManager
        self.groupListManager = groupListManager
        self.shouldShowSearchBar = shouldShowSearchBar
        self.shouldShowManageButton = shouldShowManageButton

        switch self.mode {
        case .subscribed:
            self.groupTitlePresentables = self.subscriptionManager.subscribedGroups().map { groupId in
                NewsgroupTitlePresentable(groupId: groupId)
            }
        case .all:
            self.groupListManager?.downloadGroupList { [weak self] groups in
                guard let strongSelf = self, let groups = groups else { return }

                strongSelf.groupTitlePresentables = groups.map { group in
                    NewsgroupTitlePresentable(groupId: group.groupId,
                                              numberOfMessages: group.numberOfArticles,
                                              isChecked: strongSelf.subscriptionManager.isSubscribed(toGroup: group.groupId))
                }
                strongSelf.notifyGroupInfoUpdates()
            }
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(groupSubscriptionInfoDidUpdate),
                                               name: subscriptionManager.subscriptionsDidUpdateNotification,
                                               object: nil)
    }

    private func presentables() -> [NewsgroupTitlePresentable] {
        if self.filterTerm != nil {
            return self.filteredGroupTitlePresentables
        } else {
            return self.groupTitlePresentables
        }
    }

    func numberOfNewsgroups() -> Int {
        return self.presentables().count
    }

    func titleForNewsgroup(atIndex index: Int) -> NewsgroupTitlePresentable {
        return self.presentables()[index]
    }

    func didSelectNewsgroup(atIndex index: Int) {
        guard let groupSelectionCallback = self.groupSelectionCallback else { return }

        let newsgroupTitlePresentable = self.titleForNewsgroup(atIndex: index)
        groupSelectionCallback(newsgroupTitlePresentable.groupId)
    }

    func didSelectManage() {
        self.groupManagementCallback?()
    }

    func downloadGroupListAndUpdate() {
        guard let groupListManager = self.groupListManager else { return }

        groupListManager.downloadGroupList { [weak self] groupInfos in
            guard let strongSelf = self, let groupInfos = groupInfos else {
                return
            }

            strongSelf.groupTitlePresentables = groupInfos.map { group in
                NewsgroupTitlePresentable(groupId: group.groupId,
                                          numberOfMessages: group.numberOfArticles,
                                          isChecked: strongSelf.subscriptionManager.isSubscribed(toGroup: group.groupId))
            }
            strongSelf.notifyGroupInfoUpdates()
        }
    }

    func notifyGroupInfoUpdates() {
        self.groupInfoUpdateCallback?()
    }

    @objc func groupSubscriptionInfoDidUpdate() {
        switch self.mode {
        case .subscribed:
            self.groupTitlePresentables = self.subscriptionManager.subscribedGroups().map { groupId in
                NewsgroupTitlePresentable(groupId: groupId)
            }
        case .all:
            self.groupTitlePresentables = self.groupTitlePresentables.map { presentable in
                NewsgroupTitlePresentable(groupId: presentable.groupId,
                                          numberOfMessages: presentable.numberOfMessages,
                                          isChecked: self.subscriptionManager.isSubscribed(toGroup: presentable.groupId))
            }
        }

        self.notifyGroupInfoUpdates()
    }
}
