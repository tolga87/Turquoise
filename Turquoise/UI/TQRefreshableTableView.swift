import Foundation
import UIKit


class TQRefreshableTableView : UITableView {
  var refreshCallback: (() -> Void)?

  private var refreshView: TQRefreshView!
  private var pullDownToRefreshMessage = "Pull down to refresh"

  override func awakeFromNib() {
    super.awakeFromNib()

    self.refreshControl = UIRefreshControl()
    self.refreshControl!.addTarget(self, action: #selector(didTriggerRefresh), for: .valueChanged)
    self.refreshControl!.backgroundColor = .black  // for some reason, the refresh control doesn't look right
                                                   // during scrolling if this is not set
    self.refreshControl!.layer.cornerRadius = 8
    self.refreshControl!.clipsToBounds = true

    self.refreshView = TQRefreshView.fromNib()
    self.refreshView.backgroundColor = UIColor(displayP3Red: 0.0 / 255.0,
                                               green: 00.0 / 255.0,
                                               blue: 128.0 / 255.0,
                                               alpha: 1)
    self.refreshControl!.addSubview(self.refreshView)
  }

  private func loadingMessage(_ progress: Int? = nil) -> String {
    if let progress = progress {
      return "Loading \(progress)%..."
    } else {
      return "Loading..."
    }
  }

  func beginRefreshing() {
    self.setContentOffset(CGPoint(x: 0, y: -60),
                          animated: true)
    self.refreshControl!.beginRefreshing()
    self.refreshView.titleLabel.text = self.loadingMessage()

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(didUpdateHeaderDownloadProgress(_:)),
                                           name: TQNNTPGroup.headerDownloadProgressNotification,
                                           object: nil)
  }

  func didUpdateHeaderDownloadProgress(_ notification: Notification) {
    let progress = notification.userInfo?[TQNNTPGroup.headerDownloadProgressAmountKey] as? Int
    self.refreshView.titleLabel.text = self.loadingMessage(progress)
  }

  func endRefreshing() {
    self.refreshControl?.endRefreshing()

    self.refreshView.titleLabel.text = ""
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      self.refreshView.titleLabel.text = self.pullDownToRefreshMessage
    }

    NotificationCenter.default.removeObserver(self)
  }

  func didTriggerRefresh() {
    self.refreshView.titleLabel.text = self.loadingMessage()
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(didUpdateHeaderDownloadProgress(_:)),
                                           name: TQNNTPGroup.headerDownloadProgressNotification,
                                           object: nil)

    if let refreshCallback = self.refreshCallback {
      refreshCallback()
    } else {
      self.endRefreshing()
    }
  }
}
