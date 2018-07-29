import Foundation
import UIKit

class PasswordField : TextField, UITextFieldDelegate {
    static let kMaxPasswordLength = 64

    private(set) var password = ""

    override var text: String? {
        get {
            return super.text
        }
        set {
            var newText = newValue
            if self.password.count != newValue?.count {
                // this only happens when the text is modified programmatically.
                // when change is done through the UI, we already have the correct password here.
                self.password = newValue ?? ""
            }
            newText = PasswordField.hiddenString(self.password)
            super.text = newText
        }
  }

    static func hiddenString(_ string: String) -> String {
        let count = min(kMaxPasswordLength, string.count)
        return String(repeating: "*", count: count)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.password = ""
        self.delegate = self
        self.autocorrectionType = UITextAutocorrectionType.no
        self.addTarget(self, action: #selector(textUpdated), for: UIControl.Event.editingChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func textUpdated() {
        self.text = self.password
    }

    // MARK: - UITextFieldDelegate

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = self.text, let theRange = Range(range, in:text) {
            self.password.replaceSubrange(theRange, with: string)
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // text field will be cleared, clear password as well.
        self.password = ""
        return true
    }
}
