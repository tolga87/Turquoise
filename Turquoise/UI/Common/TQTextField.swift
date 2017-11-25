import Foundation
import UIKit

class TQTextField : UITextField, UITextFieldDelegate {
  static let kMaxPasswordLength = 64

  var isPassword: Bool = false {
    didSet {
      text = ""
      password = isPassword ? "" : nil
    }
  }

  private(set) var password: String? = ""

  override var text: String? {
    get {
      return super.text
    }
    set {
      var newText = newValue
      if isPassword {
        if password?.count != newValue?.count {
          // this only happens when the text is modified programmatically.
          // when change is done through the UI, we already have the correct password here.
          password = newValue
        }
        newText = type(of: self).hiddenString(password)
      } else {
        password = ""
      }
      super.text = newText
    }
  }

  static func hiddenString(_ string: String?) -> String? {
    if let theString = string {
      let count = min(kMaxPasswordLength, theString.count)
      return String.init(repeating: "*", count: count)
    } else {
      return nil
    }
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    password = ""
    delegate = self
    autocorrectionType = UITextAutocorrectionType.no
    addTarget(self, action: #selector(textUpdated), for: UIControlEvents.editingChanged)
  }

  func textUpdated() {
    if isPassword {
      text = password
    }
  }

  // MARK: - UITextFieldDelegate

  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    if isPassword {
      if let theRange = Range(range, in:text!) {
        password?.replaceSubrange(theRange, with: string)
      }
    }
    return true
  }

  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    // text field will be cleared, clear password as well.
    password = ""
    return true
  }

  // MARK: - UITextField Overrides

  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: 10, dy: 0)
  }

  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: 10, dy: 0)
  }
}
