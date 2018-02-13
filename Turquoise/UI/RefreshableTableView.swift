import UIKit

class RefreshableTableView: UITableView {
  override func awakeFromNib() {
    super.awakeFromNib()

    self.refreshControl = UIRefreshControl()
    self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
    self.refreshControl!.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    self.addSubview(self.refreshControl!)
  }

  func didPullToRefresh() {
    print("REFRESHING...")

    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      self.reloadData()
      self.refreshControl?.endRefreshing()
    }
  }

}
