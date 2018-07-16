//
//  GroupViewController_New.swift
//  Turquoise
//
//  Created by tolga on 7/15/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

class GroupViewController_New : UIViewController {
    let groupManager: GroupManager
    var tableView: UITableView!
    let groupViewModel: TQGroupTableViewDataSource

    init(groupManager: GroupManager) {
        self.groupManager = groupManager
        self.groupViewModel = TQGroupTableViewDataSource(groupManager: self.groupManager)

        self.tableView = UITableView()
        self.tableView.register(TQArticleHeaderTableViewCell.self,
                                forCellReuseIdentifier: TQArticleHeaderTableViewCell.reuseId)
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.tableView)

        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        self.view.backgroundColor = .black
    }

    private func refreshGroupHeaders() {
        self.groupManager.downloadGroupHeaders()
    }
}
