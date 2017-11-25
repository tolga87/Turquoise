import Foundation
import UIKit

class TQOverlay : NSObject, UIGestureRecognizerDelegate {
  static let sharedInstance = TQOverlay()

  static let animationDuration = TimeInterval(0.2)

  // Extensions:
  // TODO: reorganize
  var slidingMenu: TQOverlaySlidingMenu?
  var scrollingView: UIView?
  private(set) var overlayView: TQOverlayBackgroundView?

  func show(with contentView: UIView?, animated: Bool) {
    self.show(with: contentView, relativeVerticalPosition: 0.5, animated: animated)
  }

  func show(with contentView: UIView?, relativeVerticalPosition: CGFloat, animated: Bool) {
    self.overlayView?.removeFromSuperview()

    let window = UIApplication.shared.keyWindow!
    let frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height)
    self.overlayView = TQOverlayBackgroundView(frame: frame)

    self.overlayView!.relativeVerticalPosition = relativeVerticalPosition
    self.overlayView!.translatesAutoresizingMaskIntoConstraints = false
    self.overlayView!.backgroundColor = UIColor.black.withAlphaComponent(0.7)

    if let contentView = contentView {
      contentView.translatesAutoresizingMaskIntoConstraints = false
      self.overlayView?.addSubview(contentView)
    }

    let overlayBackgroundTapRecognizer = UITapGestureRecognizer(target: self,
                                                                action: #selector(overlayViewDidTapBackground(_:)))

    overlayBackgroundTapRecognizer.delegate = self
    self.overlayView?.addGestureRecognizer(overlayBackgroundTapRecognizer)

    if animated {
      self.overlayView?.alpha = 0
      UIView.animate(withDuration: TQOverlay.animationDuration, animations: {
        self.overlayView?.alpha = 1
      })
    }

    if let overlayView = self.overlayView {
      window.addSubview(overlayView)
    }

  }

  // TODO: Fix all the "dismissWithAnimated"s in obj-c code
  func dismiss(animated: Bool) {
    let completion: (Bool) -> Void = { (finished: Bool) -> Void in
      self.overlayView?.removeFromSuperview()
      self.overlayView = nil
    }

    // prevent recognizing gestures during dismissal
    self.overlayView?.isUserInteractionEnabled = false

    if animated {
      UIView.animate(withDuration: TQOverlay.animationDuration,
                     animations: {
                      self.overlayView?.alpha = 0
      }, completion: completion)
    } else {
      completion(true)
    }
  }

  @objc func overlayViewDidTapBackground(_ gestureRecognizer: UIGestureRecognizer) {
    if self.slidingMenu != nil {
      TQOverlaySlidingMenu.dismissSlidingMenu(completion: nil)
    }
  }


  // MARK: - UIGestureRecognizerDelegate

  @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return touch.view == self.overlayView
  }

}
