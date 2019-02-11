//
//  SubscriptionManager.swift
//  Turquoise
//
//  Created by tolga on 7/29/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

typealias SubscriptionUpdateCallback = () -> Void

protocol SubscriptionManagerInterface: AnyObject {
//    var updateCallback: SubscriptionUpdateCallback? { get set }
    var subscriptionsDidUpdateNotification: NSNotification.Name { get }
    func subscribedGroups() -> [String]
    func isSubscribed(toGroup groupId: String) -> Bool
    func subscribe(toGroup groupId: String)
    func unsubscribe(fromGroup groupId: String)
    func toggleSubscription(forGroup groupId: String)
    func unsubscribeFromAll()
}

class SubscriptionManager: SubscriptionManagerInterface {
//    var updateCallback: SubscriptionUpdateCallback?

    private static let UserDefaultsSubscriptionsKey = "Subscriptions"

    static let sharedInstance = SubscriptionManager()

    private static func userDefaultsKey(for groupId: String) -> String {
        return "\(UserDefaultsSubscriptionsKey).\(groupId)"
    }

    var subscriptionsDidUpdateNotification = NSNotification.Name("SubscriptionsDidUpdate")

    func subscribedGroups() -> [String] {
        let subscriptions = UserDefaults.standard.dictionary(forKey: SubscriptionManager.UserDefaultsSubscriptionsKey) ?? [:]
        return subscriptions.keys.sorted { $0 < $1 }
    }

    func isSubscribed(toGroup groupId: String) -> Bool {
        let subs = UserDefaults.standard.dictionary(forKey: SubscriptionManager.UserDefaultsSubscriptionsKey) ?? [:]
        return subs[groupId] as? Bool ?? false
    }

    func subscribe(toGroup groupId: String) {
        var subs = UserDefaults.standard.dictionary(forKey: SubscriptionManager.UserDefaultsSubscriptionsKey) ?? [:]
        subs[groupId] = true
        UserDefaults.standard.set(subs, forKey: SubscriptionManager.UserDefaultsSubscriptionsKey)
        NotificationCenter.default.post(name: self.subscriptionsDidUpdateNotification, object: self)
    }

    func unsubscribe(fromGroup groupId: String) {
        var subs = UserDefaults.standard.dictionary(forKey: SubscriptionManager.UserDefaultsSubscriptionsKey) ?? [:]
        subs.removeValue(forKey: groupId)
        UserDefaults.standard.set(subs, forKey: SubscriptionManager.UserDefaultsSubscriptionsKey)
        NotificationCenter.default.post(name: self.subscriptionsDidUpdateNotification, object: self)
    }

    func toggleSubscription(forGroup groupId: String) {
        if self.isSubscribed(toGroup: groupId) {
            self.unsubscribe(fromGroup: groupId)
        } else {
            self.subscribe(toGroup: groupId)
        }
    }

    func unsubscribeFromAll() {
        UserDefaults.standard.removeObject(forKey: SubscriptionManager.UserDefaultsSubscriptionsKey)
        NotificationCenter.default.post(name: self.subscriptionsDidUpdateNotification, object: self)
    }
}
