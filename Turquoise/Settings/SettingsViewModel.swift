//
//  SettingsViewModel.swift
//  Turquoise
//
//  Created by tolga on 8/5/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewModel: NSObject {
    static let tableViewCellReuseId = "SettingCell"
    private let options: [SettingOption]

    required init(options: [SettingOption]) {
        self.options = options
    }
}

extension SettingsViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsViewModel.tableViewCellReuseId, for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .defaultFont(ofSize: 12)

        let option = self.options[indexPath.row]
        cell.textLabel?.text = option.title
        return cell
    }
}

extension SettingsViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = self.options[indexPath.row]

        option.callback()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
