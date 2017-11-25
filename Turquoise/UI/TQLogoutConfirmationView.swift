import Foundation
import UIKit

public class TQLogoutConfirmationView : UIView {
  public class func loadFromNib() -> TQLogoutConfirmationView? {
    return UIView.tq_load(from: "TQLogoutConfirmationView", owner: self) as? TQLogoutConfirmationView
  }

  @IBAction func cancelButtonDidTap(_ sender: Any?) {
    TQOverlay.sharedInstance.dismiss(animated: true)
  }

  @IBAction func logoutButtonDidTap(_ sender: Any?) {
    TQUserInfoManager.sharedInstance.resetUserCredentials()
    TQOverlay.sharedInstance.dismiss(animated: true)
  }
}
