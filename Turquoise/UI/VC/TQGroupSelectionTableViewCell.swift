import Foundation
import UIKit

class TQGroupSelectionTableViewCell : UITableViewCell {
  var group: TQNNTPGroup? {
    didSet {
      self.updateSubscriptionStatus()

      guard let group = self.group else {
        self.groupNameLabel.attributedText = nil
        return
      }

      let numArticles = abs(group.maxArticleNo - group.minArticleNo) + 1
      let numArticlesString = String(numArticles)
      var moderatedString: String?
      if group.moderated {
        moderatedString = " [moderated]"
      }

      let text = "\(group.groupId) \(numArticlesString)\(moderatedString ?? "")"

      let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor,
                                  value: UIColor(displayP3Red: 0, green: 0.5, blue: 0, alpha: 1),
                                  range: (text as NSString).range(of: numArticlesString))
      if let moderatedString = moderatedString {
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor,
                                    value: UIColor.red,
                                    range: (text as NSString).range(of: moderatedString))
      }

      self.groupNameLabel.attributedText = attributedText
    }
  }

  @IBOutlet var statusIconView: UIImageView!
  @IBOutlet var groupNameLabel: UILabel!

  class func evenColor() -> UIColor {
    return UIColor(displayP3Red: 8.0 / 255.0,
                   green: 20.0 / 255.0,
                   blue: 50.0 / 255.0,
                   alpha: 1)
  }

  class func oddColor() -> UIColor {
    return UIColor(displayP3Red: 8.0 / 255.0,
                   green: 20.0 / 255.0,
                   blue: 0.0 / 255.0,
                   alpha: 1)
  }


  override func awakeFromNib() {
    super.awakeFromNib()

    self.updateSubscriptionStatus()

    // TODO: make this notification system smarter.
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(userSubscriptionsDidUpdate(_:)),
                                           name: TQUserInfoManager.sharedInstance.userSubscriptionsDidChangeNotification,
                                           object: nil)
  }

  func updateSubscriptionStatus() {
    var subscribed = false
    if let group = self.group {
      subscribed = TQUserInfoManager.sharedInstance.isSubscribedTo(group: group)
    }
    self.statusIconView.image = subscribed ? UIImage(named: "check1.png")
                                           : nil
  }





    @objc func userSubscriptionsDidUpdate(_ notification: Notification) {
    self.updateSubscriptionStatus()
  }


}
