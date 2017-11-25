import Foundation
import UIKit

extension UIView {
  class func tq_load(from nibName: String, owner: Any) -> UIView? {
    let objects = Bundle.main.loadNibNamed(nibName, owner: owner, options: nil)
    return objects?[0] as? UIView
  }
}
