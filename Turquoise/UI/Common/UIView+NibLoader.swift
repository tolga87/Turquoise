import Foundation
import UIKit

public extension UIView {
  public class func tq_load(from nibName: String, owner: Any) -> UIView? {
    let objects = Bundle.main.loadNibNamed(nibName, owner: owner, options: nil)
    return objects?[0] as? UIView
  }
}
