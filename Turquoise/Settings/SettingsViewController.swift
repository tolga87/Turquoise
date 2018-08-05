//
//  SettingsViewController.swift
//  Turquoise
//
//  Created by tolga on 7/22/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    let viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Settings"

        self.view.backgroundColor = .black
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: SettingsViewModel.tableViewCellReuseId)
        self.tableView.tableFooterView = UIView()

        self.tableView.dataSource = self.viewModel
        self.tableView.delegate = self.viewModel
    }
}
