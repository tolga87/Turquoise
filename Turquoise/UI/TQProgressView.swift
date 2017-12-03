import Foundation
import UIKit

class TQProgressView : UIView {
  var progressIndicatorView: UIView!
  var progressIndicatorViewWidthConstraint: NSLayoutConstraint?

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.progressIndicatorView = UIView()
    self.progressIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    self.progressIndicatorView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0.5, alpha: 1)
    self.addSubview(self.progressIndicatorView)

    self.addConstraints([
      NSLayoutConstraint(item: self.progressIndicatorView,
                         attribute: .centerX,
                         relatedBy: .equal,
                         toItem: self,
                         attribute: .centerX,
                         multiplier: 1,
                         constant: 0),
      NSLayoutConstraint(item: self.progressIndicatorView,
                         attribute: .centerY,
                         relatedBy: .equal,
                         toItem: self,
                         attribute: .centerY,
                         multiplier: 1,
                         constant: 0),
      NSLayoutConstraint(item: self.progressIndicatorView,
                         attribute: .height,
                         relatedBy: .equal,
                         toItem: self,
                         attribute: .height,
                         multiplier: 1,
                         constant: 0),
       ])
    self.backgroundColor = .clear
    self.setProgress(0.0)

    NotificationCenter.default.addObserver(forName: TQNNTPGroup.headerDownloadProgressNotification,
                                           object: nil,
                                           queue: .main) { (notification) in
                                            if let progress = self.getProgress(from: notification) {
                                              self.setProgress(progress, animated: true)
                                            }
    }
    NotificationCenter.default.addObserver(forName: TQNNTPManager.sharedInstance.NNTPGroupDidUpdateNotification,
                                           object: nil,
                                           queue: .main) { (notification) in
                                            NotificationCenter.default.removeObserver(self)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                              self.setProgress(0.0)
                                            }
    }
  }

  func getProgress(from notification: Notification) -> Double? {
    guard let progressValue = notification.userInfo?[TQNNTPGroup.headerDownloadProgressAmountKey] else {
      return nil
    }
    guard let progressPercentage = progressValue as? Int else {
      return nil
    }

    let progress = Double(progressPercentage) / 100.0
    return progress
  }

  func setProgress(_ progress: Double, animated: Bool = false) {
    let clampedProgress = min(max(0.0, progress), 1.0)
    if let constraint = self.progressIndicatorViewWidthConstraint {
      self.removeConstraint(constraint)
    }

    self.progressIndicatorViewWidthConstraint = NSLayoutConstraint(item: self.progressIndicatorView,
                                                                   attribute: .width,
                                                                   relatedBy: .equal,
                                                                   toItem: self,
                                                                   attribute: .width,
                                                                   multiplier: CGFloat(clampedProgress),
                                                                   constant: 0)
    self.addConstraint(self.progressIndicatorViewWidthConstraint!)

    if animated {
      UIView.animate(withDuration: 0.2) {
        self.layoutIfNeeded()
      }
    }
  }
}
