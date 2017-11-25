import Foundation
import UIKit

class TQArticleHeaderTableViewCell : UITableViewCell {
  @IBOutlet var paddingView: UIView!
  @IBOutlet var articleTitleLabel: UILabel!
  @IBOutlet var articleSenderLabel: UILabel!
  @IBOutlet var paddingViewWidthConstraint: NSLayoutConstraint!

  var articleLevel: Int = 0 {
    didSet {
      self.paddingViewWidthConstraint.constant = CGFloat(4 * self.articleLevel)
    }
  }

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
}
