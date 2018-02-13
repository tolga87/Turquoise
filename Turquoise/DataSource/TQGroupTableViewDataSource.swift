import Foundation
import UIKit

class TQGroupTableViewDataSource : NSObject, UITableViewDataSource {
  var refreshCallback: (() -> Void)?

  weak var tableView: TQRefreshableTableView? {
    didSet {
      if let tableView = tableView {
        tableView.refreshCallback = {
          self.refreshGroup()
        }
      }
    }
  }

//  var nntpManager: TQNNTPManager!
  var group: TQNNTPGroup?
  var expandedArticleForest: [TQNNTPArticle]? {
    return self.group?.articleForest?.expandedForest()
  }
  var selectedArticle: TQNNTPArticle?

  public init(tableView: TQRefreshableTableView?, group: TQNNTPGroup?) {
    self.group = group
    self.tableView = tableView

    super.init()

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(headersDidUpdate),
                                           name: TQNNTPManager.NNTPGroupDidReceiveHeadersNotification,
                                           object: nil)
  }

  private func refreshGroup() {
    if let refreshCallback = self.refreshCallback {
      refreshCallback()
    }
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

  func headersDidUpdate() {
    self.tableView?.reloadData()
    self.tableView?.endRefreshing()
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
