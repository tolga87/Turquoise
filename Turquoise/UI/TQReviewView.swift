import Foundation
import UIKit

class TQReviewView : UIView {
  @IBOutlet var iconView: UIImageView!

  class func loadFromNib() -> TQReviewView? {
    let view = UIView.tq_load(from: "TQReviewView", owner: self) as? TQReviewView
    if let view = view {
      view.layer.cornerRadius = 4.0
      view.clipsToBounds = true
      view.iconView.layer.cornerRadius = 12.0
      view.iconView.clipsToBounds = true
    }
    return view
  }

  @IBAction func dismissButtonDidTap(_ sender: UIButton) {
    TQOverlay.sharedInstance.dismiss(animated: true)
  }

  @IBAction func okButtonDidTap(_ sender: UIButton) {
    TQOverlay.sharedInstance.dismiss(animated: true)
    TQReviewManager.sharedInstance.requestReview()
  }
}
