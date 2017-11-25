import Foundation
import Security

public class TQUserInfoManager {
  let kUserNameKey = kSecAttrAccount as String
  let kPasswordKey = kSecValueData as String
  let kFullNameKey = kSecAttrLabel as String
  let kEmailKey = kSecAttrService as String

  public let userSubscriptionsDidChangeNotification = Notification.Name("userSubscriptionsDidChangeNotification")
  public let userDidLogoutNotification = Notification.Name("userDidLogoutNotification")
  public let groupsKey = "userInfo.groups"

  public static let sharedInstance = TQUserInfoManager()

  public var userName: String? {
    get {
      return self.userInfoValueFor(key: kUserNameKey) as! String?
    }
    set {
      self.setUserInfo(value: newValue as NSCoding?, forKey: kUserNameKey)
    }
  }

  public var password: String? {
    get {
      return self.userInfoValueFor(key: kPasswordKey) as! String?
    }
    set {
      self.setUserInfo(value: newValue as NSCoding?, forKey: kPasswordKey)
    }
  }

  public var fullName: String? {
    get {
      return self.userInfoValueFor(key: kFullNameKey) as! String?
    }
    set {
      self.setUserInfo(value: newValue as NSCoding?, forKey: kFullNameKey)
    }
  }

  public var email: String? {
    get {
      return self.userInfoValueFor(key: kEmailKey) as! String?
    }
    set {
      self.setUserInfo(value: newValue as NSCoding?, forKey: kEmailKey)
    }
  }
  public var sortedSubscribedGroupIds: [String]? {
    get {
      guard let subscribedGroups = self.subscribedGroups else {
        return nil
      }

      return subscribedGroups.keys.sorted { (string1, string2) -> Bool in
        string1.localizedCompare(string2) == .orderedAscending
      }
    }
  }

  private var keychain: KeychainWrapper!
  public var subscribedGroups: [String : Any]?

  public init() {
    let serviceName = Bundle.main.bundleIdentifier ?? "AyranKeychainService"
    self.keychain = KeychainWrapper(serviceName: serviceName)

    self.subscribedGroups = UserDefaults.standard.object(forKey: self.groupsKey) as! [String : Any]?
    if self.subscribedGroups == nil {
      self.subscribedGroups = [ "metu.ceng.test" : 1 ]
      UserDefaults.standard.set(self.subscribedGroups, forKey:self.groupsKey)
    }
  }

  // MARK: -

  public func resetUserCredentials() {
    // TODO: it's probably a good idea to check the return value here.
    _ = self.keychain.removeAllKeys()
    self.subscribedGroups = [ "metu.ceng.test" : 1 ]
    UserDefaults.standard.set(self.subscribedGroups, forKey: self.groupsKey)
    NotificationCenter.default.post(name: self.userDidLogoutNotification, object: self)
  }

  public func isSubscribedTo(group: TQNNTPGroup) -> Bool {
    if self.subscribedGroups == nil {
      // TODO: error
      return false
    }
    return self.subscribedGroups![group.groupId] != nil
  }

  public func subscribeTo(group: TQNNTPGroup) {
    if self.subscribedGroups == nil {
      // TODO: error
      return
    }

    self.subscribedGroups![group.groupId] = 1
    UserDefaults.standard.set(self.subscribedGroups, forKey: self.groupsKey)
    NotificationCenter.default.post(name: self.userSubscriptionsDidChangeNotification, object: self)
    printInfo("Subscribed to group '\(group.groupId)'")
  }

  public func unsubscribeFrom(group: TQNNTPGroup) {
    if self.subscribedGroups == nil {
      // TODO: error
      return
    }

    self.subscribedGroups!.removeValue(forKey: group.groupId)
    UserDefaults.standard.set(self.subscribedGroups!, forKey: self.groupsKey)
    NotificationCenter.default.post(name: self.userSubscriptionsDidChangeNotification, object: self)
    printInfo("Unsubscribed from group '\(group.groupId)'")
  }

  public func userInfoValueFor(key: String) -> Any? {
    return self.keychain.object(forKey: key)
  }

  public func setUserInfo(value: NSCoding?, forKey key: String) {
    if let value = value {
      self.keychain.set(value, forKey: key)
    } else {
      self.keychain.removeObject(forKey: key)
    }
  }



}
