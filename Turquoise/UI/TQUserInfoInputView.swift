import Foundation
import UIKit

public typealias TQUserInfoInputViewCompletionBlock = (String, String) -> Void

public class TQUserInfoInputView : UIView {
  public var completionBlock: TQUserInfoInputViewCompletionBlock?

  @IBOutlet var userFullNameTextField: TQTextField!
  @IBOutlet var userEmailTextField: TQTextField!

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
