import Foundation
import UIKit

class TQArticleHeaderTableViewCell : UITableViewCell {
  @IBOutlet var paddingView: UIView!
  @IBOutlet var articleTitleLabel: UILabel!
  @IBOutlet var articleSenderLabel: UILabel!
  @IBOutlet var paddingViewWidthConstraint: NSLayoutConstraint!

  weak var article: TQNNTPArticle?

  var articleLevel: Int = 0 {
    didSet {
      self.paddingViewWidthConstraint.constant = CGFloat(4 * self.articleLevel)
    }
  }

  class var evenColor: UIColor {
    return UIColor(displayP3Red: 8.0 / 255.0,
                   green: 20.0 / 255.0,
                   blue: 50.0 / 255.0,
                   alpha: 1)
  }

  class var oddColor: UIColor {
    return UIColor(displayP3Red: 8.0 / 255.0,
                   green: 20.0 / 255.0,
                   blue: 0.0 / 255.0,
                   alpha: 1)
  }

  class var unreadTitleColor: UIColor {
    return .white
  }

  class var readTitleColor: UIColor {
    return UIColor(white: 0.6, alpha: 1)
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    self.article = nil
    self.articleTitleLabel.textColor = TQArticleHeaderTableViewCell.unreadTitleColor
  }

  @objc func didReceiveArticleReadNotification(_ notification: Notification) {
    guard let _ = self.article else {
      return
    }
    self.updateTitleColor()
  }

  private func updateTitleColor() {
    var isArticleRead = false
    if let article = self.article {
      isArticleRead = TQReadArticlesManager.sharedInstance.isRead(article)
    }
    self.articleTitleLabel.textColor = isArticleRead ? TQArticleHeaderTableViewCell.readTitleColor
                                                     : TQArticleHeaderTableViewCell.unreadTitleColor
  }

  func updateWith(article: TQNNTPArticle) {
    self.article = article
    self.articleTitleLabel.text = article.decodedSubject
    self.articleSenderLabel.text = article.decodedFrom
    self.articleLevel = article.depth
    self.updateTitleColor()

    NotificationCenter.default.removeObserver(self)
    NotificationCenter.default.addObserver(self, selector: #selector(didReceiveArticleReadNotification(_:)),
                                           name: TQReadArticlesManager.articleMarkedAsReadNotification,
                                           object: nil)
  }
}
