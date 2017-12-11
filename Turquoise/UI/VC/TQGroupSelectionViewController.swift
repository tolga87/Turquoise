import Foundation
import UIKit

class TQGroupSelectionViewController : UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
  @IBOutlet var tableView: UITableView!
  @IBOutlet var searchBar: TQSearchBar!
  var filteredGroups: [TQNNTPGroup]?

  @IBAction func doneButtonDidTap(_ sender: Any?) {
    self.dismiss(animated: true, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.searchBar.tq_textField?.font = UIFont(name: "dungeon", size: 12)
    self.searchBar.autocapitalizationType = .none

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(newsGroupsDidUpdate(_:)),
                                           name: TQNNTPManager.NNTPGroupListDidUpdateNotification,
                                           object: nil)
  }


  func newsGroupsDidUpdate(_ notification: Notification) {
    self.tableView.reloadData()
  }

  func groups() -> [TQNNTPGroup] {
    return self.filteredGroups ?? TQNNTPManager.sharedInstance.allGroups
  }

  // MARK: - UITableViewDataSource

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.groups().count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! TQGroupSelectionTableViewCell
    cell.group = self.groups()[indexPath.row]
    cell.contentView.backgroundColor = (indexPath.row % 2 == 0)
      ? TQGroupSelectionTableViewCell.evenColor()
      : TQGroupSelectionTableViewCell.oddColor()
    return cell
  }

  // MARK: - UITableViewDelegate

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let group = self.groups()[indexPath.row]
    let userInfoManager = TQUserInfoManager.sharedInstance
    if userInfoManager.isSubscribedTo(group: group) {
      userInfoManager.unsubscribeFrom(group: group)
    } else {
      userInfoManager.subscribeTo(group: group)
    }

    tableView.deselectRow(at: indexPath, animated: false)
  }

  // MARK: - UISearchBarDelegate

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      self.filteredGroups = nil
    } else {
      self.filteredGroups = TQNNTPManager.sharedInstance.allGroups.filter{ (group) -> Bool in
        group.groupId.localizedCaseInsensitiveContains(searchText)
      }
    }

    tableView.reloadData()
  }
}
