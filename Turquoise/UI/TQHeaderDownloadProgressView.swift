import Foundation
import UIKit

class TQHeaderDownloadProgressView : UIView {
  var groupId: String? {
    didSet {
      var text = "Downloading headers"
      if let groupId = groupId {
        text += " for group:\n'\(groupId)'..."
      }
      self.infoLabel.text = text
    }
  }

  @IBOutlet var progressIndicator: UIActivityIndicatorView!
  @IBOutlet var infoLabel: UILabel!
  @IBOutlet var progressLabel: UILabel!

  class func loadFromNib(groupId: String) -> TQHeaderDownloadProgressView? {
    guard let view = UIView.tq_load(from: "TQHeaderDownloadProgressView", owner: self) as? TQHeaderDownloadProgressView else {
      return nil
    }

    view.groupId = groupId
    view.progressLabel.text = "0%"
    view.progressIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    NotificationCenter.default.addObserver(view,
                                           selector: #selector(progressDidUpdate(_:)),
                                           name: TQNNTPGroup.headerDownloadProgressNotification,
                                           object: nil)
    return view
  }

  func progressDidUpdate(_ notification: Notification) {
    if let progress = notification.userInfo?[TQNNTPGroup.headerDownloadProgressAmountKey] {
      self.progressLabel.text = "\(progress)%"
    }
  }
}
