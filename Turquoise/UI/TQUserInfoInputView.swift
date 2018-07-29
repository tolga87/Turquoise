import Foundation
import UIKit

typealias TQUserInfoInputViewCompletionBlock = (String, String) -> Void

class TQUserInfoInputView : UIView {
  var completionBlock: TQUserInfoInputViewCompletionBlock?

  @IBOutlet var userFullNameTextField: PasswordField!
  @IBOutlet var userEmailTextField: PasswordField!

  @IBAction func proceedButtonDidTap(_ sender: Any?) {
    let userFullName = self.userFullNameTextField.text?.tq_whitespaceAndNewlineStrippedString ?? ""
    let userEmail = self.userEmailTextField.text?.tq_whitespaceAndNewlineStrippedString ?? ""
    guard !userFullName.isEmpty, !userEmail.isEmpty else {
      return
    }

    // TODO: verify email format
    self.completionBlock?(userFullName, userEmail)
    TQOverlay.sharedInstance.dismiss(animated: true)
  }
}
