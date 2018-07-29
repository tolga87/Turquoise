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

    var fontSize: CGFloat {
        get {
            return self.font.pointSize
        }
        set {
            self.font = UIFont(name: "dungeon", size: newValue)
        }

    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont(name: "dungeon", size: self.font.pointSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
        super.drawText(in: rect.inset(by: insets))
    }
}
