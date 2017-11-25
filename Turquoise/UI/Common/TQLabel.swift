import Foundation
import UIKit

class TQLabel : UILabel {
  var horizontalInset: CGFloat = 0 {
    didSet {
      setNeedsLayout()
    }
  }

  var verticalInset: CGFloat = 0 {
    didSet {
      self.setNeedsLayout()
    }
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.font = UIFont.init(name: "dungeon", size: self.font.pointSize)
  }

  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset)
    super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
  }
  
}
