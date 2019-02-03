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
    var updateCallback: SubscriptionUpdateCallback? { get set }
    func subscribe(toGroup groupId: String)
    func unsubscribe(fromGroup groupId: String)
    func isSubscribed(toGroup groupId: String) -> Bool
    func unsubscribeFromAll()
}

class SubscriptionManager: SubscriptionManagerInterface {
    var updateCallback: SubscriptionUpdateCallback?

    private static let UserDefaultsSubscriptionsKey = "Subscriptions"

    static let sharedInstance = SubscriptionManager()

    private static func userDefaultsKey(for groupId: String) -> String {
        return "\(UserDefaultsSubscriptionsKey).\(groupId)"
    }

    func subscribe(toGroup groupId: String) {
        var subs = UserDefaults.standard.dictionary(forKey: SubscriptionManager.UserDefaultsSubscriptionsKey) ?? [:]
        subs[groupId] = true
        UserDefaults.standard.set(subs, forKey: SubscriptionManager.UserDefaultsSubscriptionsKey)
        self.updateCallback?()
    }

    func unsubscribe(fromGroup groupId: String) {
        var subs = UserDefaults.standard.dictionary(forKey: SubscriptionManager.UserDefaultsSubscriptionsKey) ?? [:]
        subs.removeValue(forKey: groupId)
        UserDefaults.standard.set(subs, forKey: SubscriptionManager.UserDefaultsSubscriptionsKey)
        self.updateCallback?()
    }

    func isSubscribed(toGroup groupId: String) -> Bool {
        let subs = UserDefaults.standard.dictionary(forKey: SubscriptionManager.UserDefaultsSubscriptionsKey) ?? [:]
        return subs[groupId] as? Bool ?? false
    }

    func unsubscribeFromAll() {
        UserDefaults.standard.removeObject(forKey: SubscriptionManager.UserDefaultsSubscriptionsKey)
    }
}
