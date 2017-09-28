import Foundation
import UIKit

public class TQSearchBar : UISearchBar {
  private var theTextField: UITextField?

  public var tq_textField: UITextField? {
    get {
      if theTextField == nil {
        theTextField = findTextFieldRecursivelyStarting(at: self)
      }
      return theTextField
    }
  }

  private func findTextFieldRecursivelyStarting(at view: UIView) -> UITextField? {
    if view.isKind(of: UITextField.self) {
      return view as? UITextField
    }

    for subview in view.subviews {
      if let textField = self.findTextFieldRecursivelyStarting(at: subview) {
        return textField
      }
    }
    return nil
  }
}
