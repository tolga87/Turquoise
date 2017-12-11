import Foundation
import StoreKit

class TQReviewManager : NSObject {
  static let sharedInstance = TQReviewManager()

  static let promptDisplayedKey = "promptDisplayedKey"
  static let listenedNotificationsKey = "listenedNotificationsKey"

  private var promptTimerStartTime: TimeInterval = 0
  private var promptCheckTimer: Timer?
  private var windowCount = 0

  private var listenedNotifications: [Notification.Name : Int] = [
    TQNNTPManager.didReceiveArticleBodyNotification : 10,
    TQGroupViewController.userDidChangeGroupNotification: 10,
    TQNNTPManager.didPostArticleNotification : 1,
  ]
  private var promptDisplayed = false {
    didSet {
      UserDefaults.standard.set(promptDisplayed, forKey: TQReviewManager.promptDisplayedKey)
    }
  }

  override init() {
    super.init()

    self.promptDisplayed = UserDefaults.standard.bool(forKey: TQReviewManager.promptDisplayedKey)

    if !self.promptDisplayed {
      if let notifDict = UserDefaults.standard.object(forKey: TQReviewManager.listenedNotificationsKey) as! [Notification.Name : Int]? {
        self.listenedNotifications = notifDict
      }
      for (notificationName, _) in self.listenedNotifications {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveNotification(_:)),
                                               name: notificationName,
                                               object: nil)
      }
    }
  }

  func showReviewPrompt() {
    if let reviewPrompt = TQReviewView.loadFromNib() {
      TQOverlay.sharedInstance.show(with: reviewPrompt, relativeVerticalPosition: 0.35, animated: true)
      self.promptDisplayed = true
    }
  }

  func requestReview(useAppStore: Bool = false) {
    if useAppStore {
      self.openAppStoreReviewLink()
      return
    }

    if #available(iOS 10.3, *) {
      self.startPromptListener(pollInterval: 0.1, timeout: 3)
      SKStoreReviewController.requestReview()
    } else {
      self.openAppStoreReviewLink()
    }
  }

  @objc private func didReceiveNotification(_ notification: Notification) {
    guard var count = self.listenedNotifications[notification.name] else {
      let className = String(describing: type(of: self))
      printError("Received invalid notification in \(className): \(notification.name)")
      return
    }

    count -= 1
    self.listenedNotifications[notification.name] = count
    UserDefaults.standard.set(self.listenedNotifications, forKey: TQReviewManager.listenedNotificationsKey)

    printInfo("Notification '\(notification.name.rawValue)' received. Remaining count: \(count)")

    if count <= 0 {
      NotificationCenter.default.removeObserver(self)
      DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        self.showReviewPrompt()
      }
    }
  }

  private func startPromptListener(pollInterval: TimeInterval, timeout: TimeInterval) {
    self.windowCount = UIApplication.shared.windows.count
    self.promptTimerStartTime = Date.timeIntervalSinceReferenceDate
    self.promptCheckTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
      let timeElapsed = Date.timeIntervalSinceReferenceDate - self.promptTimerStartTime

      func didWindowCountChange() -> Bool {
        return (UIApplication.shared.windows.count > self.windowCount)
      }

      if didWindowCountChange() {
        // prompt detected
        self.stopPromptListener()
      } else if timeElapsed > timeout {
        // timed out
        self.stopPromptListener()
        printInfo("Launching App Store review URL...")
        self.openAppStoreReviewLink()
      }
    }
  }

  private func stopPromptListener() {
    self.promptCheckTimer?.invalidate()
    self.promptCheckTimer = nil
  }

  private func openAppStoreReviewLink() {
    guard let url = URL(string: "https://itunes.apple.com/us/app/ayran-2-0/id523995658?ls=1&mt=8&action=write-review") else {
      return
    }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
}
