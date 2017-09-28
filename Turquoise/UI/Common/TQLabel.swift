import Foundation
import UIKit

public class TQLabel : UILabel {
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

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.font = UIFont.init(name: "dungeon", size: self.font.pointSize)
  }

  public override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset)
    super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
  }
  
}
