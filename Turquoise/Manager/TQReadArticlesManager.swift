import Foundation

class TQReadArticlesManager {
  static let sharedInstance = TQReadArticlesManager()
  static let userDefaultsKey = "TQReadArticlesManagerUserDefaultsKey"
  static let articleMarkedAsReadNotification = Notification.Name("articleMarkedAsReadNotification")

  private var readArticles: [String : Int]

  init() {
    if let dict = UserDefaults.standard.dictionary(forKey: TQReadArticlesManager.userDefaultsKey) as? [String : Int] {
      self.readArticles = dict
    } else {
      self.readArticles = [:]
    }
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(userDidLogout(_:)),
                                           name: TQUserInfoManager.sharedInstance.userDidLogoutNotification,
                                           object: nil)
  }

  @objc private func userDidLogout(_ notification: Notification) {
    self.reset()
  }

  private func saveToDefaults() {
    UserDefaults.standard.setValue(self.readArticles, forKey: TQReadArticlesManager.userDefaultsKey)
    #if DEBUG
      // this is to make sure the values are stored properly during development.
      // it shouldn't be necessary on Release builds.
      UserDefaults.standard.synchronize()
    #endif
  }

  deinit {
    self.saveToDefaults()
  }

  func markAsRead(_ article: TQNNTPArticle) {
    self.readArticles[article.messageId] = 1
    self.saveToDefaults()
    NotificationCenter.default.post(name: TQReadArticlesManager.articleMarkedAsReadNotification,
                                    object: self,
                                    userInfo: nil)
    printDebug("Article \(article.messageId) marked as read.")
  }

  func isRead(_ article: TQNNTPArticle) -> Bool {
    return (self.readArticles[article.messageId] != nil)
  }

  func reset() {
    self.readArticles = [:]
    self.saveToDefaults()
  }
}
