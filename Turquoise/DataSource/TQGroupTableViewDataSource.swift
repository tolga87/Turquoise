import Foundation
import UIKit

class TQGroupTableViewDataSource : NSObject, UITableViewDataSource {
  var articleManager: TQArticleManager

  weak var tableView: TQRefreshableTableView?

  var groupId: String
  private(set) var group: TQNNTPGroup?
  var expandedArticleForest: [TQNNTPArticle]? {
    return self.group?.articleForest?.expandedForest()
  }
  var selectedArticle: TQNNTPArticle?

  public init(tableView: TQRefreshableTableView?, groupId: String, articleManager: TQArticleManager) {
    self.tableView = tableView

    self.groupId = groupId
    self.articleManager = articleManager
    self.group = self.articleManager.getGroup(id: self.groupId)

    super.init()

    self.tableView?.refreshCallback = {
      self.refreshGroup()
    }

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(groupDidUpdate(_:)),
                                           name: self.articleManager.groupDidUpdateNotification,
                                           object: nil)
    self.refreshGroup()  //~TA
  }

  func groupDidUpdate(_ notification: Notification) {
    self.group = notification.userInfo?[self.articleManager.updatedGroupKey] as? TQNNTPGroup
    self.tableView?.reloadData()
    self.tableView?.endRefreshing()
  }

  private func refreshGroup() {
    guard let tableView = self.tableView else {
      return
    }

    if !tableView.isRefreshing() {
      tableView.beginRefreshing()
    }

    self.articleManager.refreshGroupHeaders(groupId: self.groupId)
  }

  func articleAt(indexPath: IndexPath) -> TQNNTPArticle? {
    guard let forest = self.expandedArticleForest else {
      return nil
    }

    let row = indexPath.row
    if row < 0 || row >= forest.count {
      return nil
    }

    return forest[row]
  }

  // MARK: - UITableViewDataSource

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let articleForest = self.group?.articleForest else {
      return 0
    }
    return articleForest.numArticles
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleSubjectCell",
                                             for: indexPath) as! TQArticleHeaderTableViewCell
    guard let article = self.articleAt(indexPath: indexPath) else {
      return cell
    }

    cell.updateWith(article: article)  // TODO: fix
    cell.contentView.backgroundColor = (indexPath.row % 2 == 0)
      ? TQArticleHeaderTableViewCell.evenColor
      : TQArticleHeaderTableViewCell.oddColor

    return cell
  }
}
