import UIKit

class TQRefreshView: UIView {
  @IBOutlet var titleLabel: UILabel!

  class func fromNib() -> TQRefreshView {
    let contents = Bundle.main.loadNibNamed("TQRefreshView", owner: self, options: nil)!
    let view = contents[0] as! TQRefreshView
    return view
  }
}
